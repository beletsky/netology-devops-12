# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"

> Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

Вначале соберем приложение в каталоге `app` и проверим его работоспособность.
```bash
$ docker compose build
...

$ docker compose up -d
...
[+] Running 4/4
 ⠿ Network app_default       Created     0.1s
 ⠿ Container app-frontend-1  Started     2.2s
 ⠿ Container app-db-1        Started     2.2s
 ⠿ Container app-backend-1   Started     2.2s

$ curl http://localhost:9000

{"detail":"Not Found"}
 
$ curl http://localhost:8000

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

$ docker compose stop
```

Данное домашнее задание я выполнял в Minikube, что накладывает некоторые особенности на процесс и результаты выполнения. В частности, перед сборкой приложения в Docker необходимо настроить окружение на использование Docker внутри Minikube и повторно собрать образы внутри Minikube:
```bash
$ eval $(minikube docker-env)
$ docker compose build
```

## Задание 1: подготовить тестовый конфиг для запуска приложения

> Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
> * под содержит в себе 2 контейнера — фронтенд, бекенд;
> * регулируется с помощью deployment фронтенд и бекенд;
> * база данных — через statefulset.

Создадим единый файл deployment для одного пода, содержащего backend и frontend одновременно в файле `dev/app.yaml` и service и stateful-set для БД в файле `dev/db.yaml`. В целях обучения я опустил в манифестах много деталей, которые нужны в реальной эксплуатации: readiness и liveness пробы, выделение volume под содержимое БД, и т.д. Также я использовал значение `imagePullPolicy: IfNotPresent` потому что собираю образы на локальной машине и запускаю кластер в Minikube. 

Вначале запускаем и дожидаемся успешного запуска базы данных:
```bash
$ kubectl apply -f dev/db.yaml

service/db created
statefulset.apps/db created
```

Затем запускаем приложение. Отдельный запуск приложения необходим потому, что при старте бэкэнд пытается подключиться к БД, и завершается по ошибке в случае, если БД не найдена.

Мне кажется более правильным писать бэкэнд таким образом, чтобы он мог автоматически обновлять подключение к БД при необходимости, а не требовать его при старте. Однако тестовое приложение уже написано таким не самым подходящим образом. В принципе, чтобы обойти это поведение, можно в манифесте приложения описать блок `initContainers` для ожидания готовности БД. Однако в реальной работе запуск БД производится редко, и в данном случае, по моему мнению, можно обойтись без этого. 
```bash
$ kubectl apply -f dev/app.yaml

deployment.apps/dev created
```

В итоге получаем:
```bash
$ kubectl get pod

NAME                   READY   STATUS    RESTARTS   AGE
db-0                   1/1     Running   0          9s
dev-77568595b8-q4wzx   2/2     Running   0          1s
```

Для проверки того, что приложение работает, создадим port-forward на порт 80 внутри пода `dev` и в другой консоли проверим результат:
```bash
$ kubectl port-forward dev-77568595b8-q4wzx 8000:80

Forwarding from 127.0.0.1:8000 -> 80
Forwarding from [::1]:8000 -> 80
Handling connection for 8000
```
```bash
$ curl http://localhost:8000

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

Так же можно убедиться в работоспособности бэкэнда:
```bash
$ kubectl port-forward dev-77568595b8-q4wzx 9000:9000

Forwarding from 127.0.0.1:9000 -> 9000
Forwarding from [::1]:9000 -> 9000
Handling connection for 9000
```
```bash
$ curl http://localhost:9000

{"detail":"Not Found"}
```

## Задание 2: подготовить конфиг для production окружения

> Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
> * каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
> * для связи используются service (у каждого компонента свой);
> * в окружении фронта прописан адрес сервиса бекенда;
> * в окружении бекенда прописан адрес сервиса базы данных.

Для production окружения нам будет необходимо сделать следующие изменения:
- добавить для backend собственный сервис, чтобы frontend мог обращаться к нему из отдельного пода;
- добавим сразу свой сервис и для frontend, чтобы в дальнейшем можно было обращаться к нему из внешних сетей;
- в поде frontend нужно будет указать переменную окружения с адресом сервиса backend;
- добавить для backend ожидание готовности БД (так как в рамках этого задания мы не изменяем тестовое приложение).

Полученные в результате файлы манифестов приведены в каталоге `prod`.

После того, как мы добавили в манифест backend блок `initContainers`, можно запускать весь комплекс одной командой:
```bash
$ kubectl apply -f prod

service/backend created
deployment.apps/backend created
service/db created
statefulset.apps/db created
service/frontend created
deployment.apps/frontend created
```

После запуска получаем:
```bash
$ k get po
NAME                        READY   STATUS    RESTARTS   AGE
backend-579559cddd-4xtb2    1/1     Running   0          27s
db-0                        1/1     Running   0          27s
frontend-74c7bb8589-5jhq4   1/1     Running   0          27s
```

Выполняем обычную проверку:
```bash
$ kubectl port-forward frontend-74c7bb8589-5jhq4 8000:80

Forwarding from 127.0.0.1:8000 -> 80
Forwarding from [::1]:8000 -> 80
Handling connection for 8000
```
```bash
$ curl http://localhost:8000

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
$ kubectl port-forward backend-579559cddd-4xtb2 9000:9000

Forwarding from 127.0.0.1:9000 -> 9000
Forwarding from [::1]:9000 -> 9000
Handling connection for 9000
```
```bash
$ curl http://localhost:9000

{"detail":"Not Found"}
```
