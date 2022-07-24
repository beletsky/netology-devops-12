# Домашнее задание к занятию "13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet"
> В работе часто приходится применять системы автоматической генерации конфигураций. Для изучения нюансов использования разных инструментов нужно попробовать упаковать приложение каждым из них.

Возьмём для данной домашней работы [production-версию приложения](../13-01/prod), которая была сделана в [домашнем задании 13-01](../13-01).

## Задание 1: подготовить helm чарт для приложения
> Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:
> * каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;
> * в переменных чарта измените образ приложения для изменения версии.

Создадим новый чарт при помощи команды `helm create app`, перенесём в него конфигурацию нашего приложения, и вынесем требуемые для шаблонизации переменные в файл [values.yaml](app/values.yaml).

Для того чтобы иметь возможность запускать несколько экземпляров приложения в одном namespace, добавим возможность указания "идентификатора экземпляра", и будем создавать объекты Kubernetes с уникальными именами, содержащими этот идентификатор. При использовании этой возможности одновременно для каждого экземпляра приложения для его сервисов будем указывать уникальный набор портов, на которых сервисы будут принимать входящие соединения. 

Также вынесем в файл переменных возможность указания количества реплик бэкэнда и фронтэнда, и возможность указать образ (при необходимости включая его версию) и политику скачивания образа для каждого сервиса приложения.

Получаем следующий готовый [чарт](app/), который успешно проходит проверку на правильность:
```bash

$ helm lint app
==> Linting app
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

## Задание 2: запустить 2 версии в разных неймспейсах
> Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:
> * одну версию в namespace=app1;
> * вторую версию в том же неймспейсе;
> * третью версию в namespace=app2.

Проверим теперь полученный результат.

Создадим заранее namespaces для приложения:
```bash
$ kubectl create ns app1

namespace/app1 created

$ kubectl create ns app2

namespace/app2 created
```

Запускаем первую копию приложения с параметрами по умолчанию:
```bash
$ helm install app1 app --set namespace=app1

NAME: app1
LAST DEPLOYED: Sun Jul 24 03:44:20 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

$ kubectl get pod -o wide --namespace=app1

NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
backend-579559cddd-wmvmh    1/1     Running   0          42s   172.17.0.4    minikube   <none>           <none>
db-0                        1/1     Running   0          42s   172.17.0.12   minikube   <none>           <none>
frontend-74c7bb8589-svbd6   1/1     Running   0          42s   172.17.0.8    minikube   <none>           <none>
```

Запускаем вторую копию приложения в том же namespace `app1`, но переопределяя `instance` и номера портов:
```bash
$ helm install app2 app --set instance=second,namespace=app1,port.backend=9001,port.db=5433,port.frontend=81

NAME: app2
LAST DEPLOYED: Sun Jul 24 03:50:10 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

$ kubectl get pod -o wide --namespace=app1

NAME                               READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES
backend-579559cddd-wmvmh           1/1     Running   0          6m36s   172.17.0.4    minikube   <none>           <none>
backend-second-5db4dc6b7d-khw6m    1/1     Running   0          47s     172.17.0.15   minikube   <none>           <none>
db-0                               1/1     Running   0          6m36s   172.17.0.12   minikube   <none>           <none>
db-second-0                        1/1     Running   0          47s     172.17.0.17   minikube   <none>           <none>
frontend-74c7bb8589-svbd6          1/1     Running   0          6m36s   172.17.0.8    minikube   <none>           <none>
frontend-second-6b8bcf5cd6-7rdrz   1/1     Running   0          47s     172.17.0.16   minikube   <none>           <none>
```

Третью копию приложения запускаем также с параметрами по умолчанию, но в namespace `app2`:
```bash
$ helm install app3 app --set namespace=app2

NAME: app3
LAST DEPLOYED: Sun Jul 24 03:51:20 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

$ kubectl get pod -o wide --namespace=app2

NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
backend-579559cddd-zlqw9    1/1     Running   0          45s   172.17.0.18   minikube   <none>           <none>
db-0                        1/1     Running   0          45s   172.17.0.20   minikube   <none>           <none>
frontend-74c7bb8589-fcvcl   1/1     Running   0          45s   172.17.0.19   minikube   <none>           <none>
```

Итого получаем:
```bash
$ helm list

NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
app1            default         1               2022-07-24 03:44:20.9531322 +0300 MSK   deployed        app-1.0.0                       1.0.0
app2            default         1               2022-07-24 03:50:10.1532334 +0300 MSK   deployed        app-1.0.0                       1.0.0
app3            default         1               2022-07-24 03:51:20.5289294 +0300 MSK   deployed        app-1.0.0                       1.0.0
```

Проверим работоспособность всех трёх экземпляров приложения при помощи port-forward:
```bash
$ kubectl port-forward --namespace=app1 frontend-74c7bb8589-svbd6 8001:80

Forwarding from 127.0.0.1:8001 -> 80
Forwarding from [::1]:8001 -> 80
Handling connection for 8001
```
```bash
$ curl http://localhost:8001

<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
```
```bash
$ kubectl port-forward --namespace=app1 frontend-second-6b8bcf5cd6-7rdrz 8002:80

Forwarding from 127.0.0.1:8002 -> 80
Forwarding from [::1]:8002 -> 80
Handling connection for 8002
```
```bash
$ curl http://localhost:8002

<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
```
```bash
$ kubectl port-forward --namespace=app2 frontend-74c7bb8589-fcvcl 8003:80

Forwarding from 127.0.0.1:8003 -> 80
Forwarding from [::1]:8003 -> 80
Handling connection for 8003
```
```bash
$ curl http://localhost:8003

<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
```

Таким образом, мы из одного helm chart при помощи простой командной строки развернули три копии приложения, работающих одновременно. Так как я использовал для выполнения работы Minikube, все поды работают на единственной рабочей ноде (не конфликтуя друг с другом).
