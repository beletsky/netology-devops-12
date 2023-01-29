# Домашнее задание к занятию "14.4 Сервис-аккаунты"

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube

> Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
> задачу 1 как справочный материал.

### Как создать сервис-аккаунт?

Создаём сервис-аккаунт следующей командой:
```bash
$ kubectl create serviceaccount netology

serviceaccount/netology created
```

Создание сервис-аккаунта создаёт также секрет с токеном для его использования:
```bash
$ kubectl get secrets

NAME                   TYPE                                  DATA   AGE
default-token-r68rv    kubernetes.io/service-account-token   3      16h
netology-token-9p4md   kubernetes.io/service-account-token   3      3m57s

$ kubectl get secrets netology-token-9p4md -o yaml 

apiVersion: v1
data:
  ca.crt: (skipped)
  namespace: ZGVmYXVsdA==
  token: (skipped)
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: netology
    kubernetes.io/service-account.uid: 5bae6d0c-755d-4979-ae99-528d58551ca4
  creationTimestamp: "2023-01-29T09:33:09Z"
  name: netology-token-9p4md
  namespace: default
  resourceVersion: "43230"
  uid: d30e9d84-babf-496e-8a12-652011be66b9
type: kubernetes.io/service-account-token
```

### Как просмотреть список сервис-акаунтов?

Список сервис-аккаунтов выводит стандартная команда `get` для типа ресурса `serviceaccounts` (в качестве сокращения можно использовать единственное число `serviceaccount`):
```bash
$ kubectl get serviceaccounts

NAME       SECRETS   AGE
default    1         16h
netology   1         81s

$ kubectl get serviceaccount

NAME       SECRETS   AGE
default    1         16h
netology   1         2m3s
```

### Как получить информацию в формате YAML и/или JSON?

Ключи `-o yaml` и `-o json`, как обычно, выводят информацию о сервис-аккаунтах в соответствующих форматах.
```bash
$ kubectl get serviceaccount netology -o yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2023-01-29T09:33:09Z"
  name: netology
  namespace: default
  resourceVersion: "43231"
  uid: 5bae6d0c-755d-4979-ae99-528d58551ca4
secrets:
- name: netology-token-9p4md

$ kubectl get serviceaccount default -o json

{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2023-01-28T16:45:58Z",
        "name": "default",
        "namespace": "default",
        "resourceVersion": "440",
        "uid": "142793a9-5bd6-4ef9-9d50-3ba2025cdf2a"
    },
    "secrets": [
        {
            "name": "default-token-r68rv"
        }
    ]
}
```

### Как выгрузить сервис-акаунты и сохранить его в файл?

При помощи стандартной переадресации потока вывода можно записать сервис-аккаунты в файл манифеста соотвествующего типа (все сразу или только один):
```bash
$ kubectl get serviceaccounts -o json > serviceaccounts.json

$ cat serviceaccounts.json

{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "kind": "ServiceAccount",
            "metadata": {
                "creationTimestamp": "2023-01-28T16:45:58Z",
                "name": "default",
                "namespace": "default",
                "resourceVersion": "440",
                "uid": "142793a9-5bd6-4ef9-9d50-3ba2025cdf2a"
            },
            "secrets": [
                {
                    "name": "default-token-r68rv"
                }
            ]
        },
        {
            "apiVersion": "v1",
            "kind": "ServiceAccount",
            "metadata": {
                "creationTimestamp": "2023-01-29T09:33:09Z",
                "name": "netology",
                "namespace": "default",
                "resourceVersion": "43231",
                "uid": "5bae6d0c-755d-4979-ae99-528d58551ca4"
            },
            "secrets": [
                {
                    "name": "netology-token-9p4md"
                }
            ]
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": ""
    }
}

$ kubectl get serviceaccount netology -o yaml > netology.yml

$ cat netology.yml

apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2023-01-29T09:33:09Z"
  name: netology
  namespace: default
  resourceVersion: "43231"
  uid: 5bae6d0c-755d-4979-ae99-528d58551ca4
secrets:
- name: netology-token-9p4md
```

### Как удалить сервис-акаунт?

Удалить сервис-аккаунт можно при помощи команды `delete`:
```bash 

$ kubectl delete serviceaccount netology

serviceaccount "netology" deleted
```
При удалении сервис-аккаунта также удаляется связанный с ним секрет:
```bash
$ kubectl get secrets netology-token-9p4md -o yaml
 
Error from server (NotFound): secrets "netology-token-9p4md" not found
```

### Как загрузить сервис-акаунт из файла?

Также можно создать сервис-аккаунт из файла манифеста `netology.yml`, созданного ранее. Поскольку при удалении сервис-аккаунта был также удалён соответствующий ему секрет, перед импортом удалим из файла раздел с указанием связанных секретов:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2023-01-29T09:33:09Z"
  name: netology
  namespace: default
  resourceVersion: "43231"
  uid: 5bae6d0c-755d-4979-ae99-528d58551ca4
```
и применим полученный файл манифеста:
```bash
$ kubectl apply -f netology.yml

serviceaccount/netology created

$ kubectl get serviceaccount netology -o yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"ServiceAccount","metadata":{"annotations":{},"creationTimestamp":"2023-01-29T09:33:09Z","name":"netology","namespace":"default","resourceVersion":"43231","uid":"5bae6d0c-755d-4979-ae99-528d58551ca4"}}
  creationTimestamp: "2023-01-29T19:52:10Z"
  name: netology
  namespace: default
  resourceVersion: "69275"
  uid: 83ba7665-c8df-4814-ab15-14a502f92971
secrets:
- name: netology-token-gt6jm

$ kubectl get secret netology-token-gt6jm -o yaml

apiVersion: v1
data:
  ca.crt: (skipped)
  namespace: ZGVmYXVsdA==
  token: (skipped)
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: netology
    kubernetes.io/service-account.uid: 83ba7665-c8df-4814-ab15-14a502f92971
  creationTimestamp: "2023-01-29T19:52:10Z"
  name: netology-token-gt6jm
  namespace: default
  resourceVersion: "69274"
  uid: 4d9b953b-d87d-414a-8e2c-6926c0770454
type: kubernetes.io/service-account-token
```
Как видим, при создании сервис-аккаунта из файла был создан новый секрет с токеном доступа.


## Задача 2 (*): Работа с сервис-акаунтами внутри модуля

> Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить
> доступность API Kubernetes

Посмотрим, как сервис-аккаунт можно использовать для доступа к API Kubernetes изнутри контейнера. Для этого создадим следующий манифест для образа с ОС Fedora `fedora.yml:
```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: fedora
spec:
  containers:
  - name: myapp
    image: fedora:latest
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "trap : TERM INT; sleep infinity & wait" ]
  serviceAccountName: netology
```

Запустим его и убедимся, что в переменных среды имеется необходимая информация:
```bash
$ kubectl apply -f fedora.yml

pod/fedora created

$ kubectl exec fedora -- bash -c "printenv | grep KUBERNETES_SERVICE"

KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=10.96.0.1

$ kubectl exec fedora -- bash -c "ls -l /var/run/secrets/kubernetes.io/serviceaccount"

total 0
lrwxrwxrwx 1 root root 13 Jan 29 19:58 ca.crt -> ..data/ca.crt
lrwxrwxrwx 1 root root 16 Jan 29 19:58 namespace -> ..data/namespace
lrwxrwxrwx 1 root root 12 Jan 29 19:58 token -> ..data/token

$ kubectl exec fedora -- bash -c "cat /var/run/secrets/kubernetes.io/serviceaccount/token"

(skipped)

$ kubectl exec fedora -- bash -c "cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
-----BEGIN CERTIFICATE-----
(skipped)
-----END CERTIFICATE-----
```

Выполняем пробный запрос к API Kubernetes из запущенного пода:
```bash
$ kubectl exec fedora -- bash -c "curl -H \"Authorization: Bearer \$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)\" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt https://\$KUBERNETES_SERVICE_HOST:\$KUBERNETES_SERVICE_PORT/api/v1/"

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 10332    0 10332    0     0   424k      0 --:--:-- --:--:-- --:--:--  438k
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
    (skipped)
    {
      "name": "services/status",
      "singularName": "",
      "namespaced": true,
      "kind": "Service",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    }
  ]
}
```
Как видим, всё заработало.
