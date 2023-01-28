# Домашнее задание к занятию "14.3 Карты конфигураций"

## Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube

> Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
> задачу 1 как справочный материал.

### Как создать карту конфигураций?

Создаём карту конфигураций `nginx-config` из файла `nginc.conf`: 
```bash
$ kubectl create configmap nginx-config --from-file=nginx.conf

configmap/nginx-config created
```
и из строки:
```bash
$ kubectl create configmap domain --from-literal=name=example.com

configmap/domain created
```

### Как просмотреть список карт конфигураций?

Получаем информацию о созданных картах конфигураций. Ресурс `configmap` является алиасом для `configmaps`:
```bash
$ kubectl get configmaps

NAME               DATA   AGE
domain             1      66s
kube-root-ca.crt   1      3h37m
nginx-config       1      97s

$ kubectl get configmap

NAME               DATA   AGE
domain             1      80s
kube-root-ca.crt   1      3h37m
nginx-config       1      111s
```

### Как просмотреть карту конфигурации?

Указав в предыдущих командах имя карты конфигурации, можно получить краткую сводку только для неё:
```bash
$ kubectl get configmap nginx-config

NAME           DATA   AGE
nginx-config   1      2m17s
```

Полную информацию о содержимом карты конфигурации можно просмотреть так:
```bash
$ kubectl describe configmap nginx-config

Name:         nginx-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----
server {
    listen 80;
    server_name  netology.ru www.netology.ru;
    access_log  /var/log/nginx/domains/netology.ru-access.log  main;
    error_log   /var/log/nginx/domains/netology.ru-error.log info;
    location / {
        include proxy_params;
        proxy_pass http://10.10.10.10:8080/;
    }
}


BinaryData
====

Events:  <none>

$ kubectl describe configmap domain

Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
example.com

BinaryData
====

Events:  <none>
```

### Как получить информацию в формате YAML и/или JSON?

Можно сохранить информацию о карте конфигурации в формате YAML:
```bash
$ kubectl get configmap nginx-config -o yaml

apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2023-01-28T20:22:05Z"
  name: nginx-config
  namespace: default
  resourceVersion: "9891"
  uid: 46a5e0f1-96aa-4880-9211-0e2e06594c63
```
или JSON:
```bash
$ kubectl get configmap domain -o json

{
    "apiVersion": "v1",
    "data": {
        "name": "example.com"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2023-01-28T20:22:36Z",
        "name": "domain",
        "namespace": "default",
        "resourceVersion": "9914",
        "uid": "1fa8e31b-966f-4a0c-a822-6e6ab3d53a0c"
    }
}
```

### Как выгрузить карту конфигурации и сохранить его в файл?

При помощи стандартной переадресации вывода информацию о картах конфигурации (всех, или только одной) можно записать в файл:
```bash
$ kubectl get configmaps -o json > configmaps.json

$ cat configmaps.json

{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "name": "example.com"
            },
            "kind": "ConfigMap",
            "metadata": {
                "creationTimestamp": "2023-01-28T20:22:36Z",
                "name": "domain",
                "namespace": "default",
                "resourceVersion": "9914",
                "uid": "1fa8e31b-966f-4a0c-a822-6e6ab3d53a0c"
            }
        },
        {
            "apiVersion": "v1",
            "data": {
                "ca.crt": "-----BEGIN CERTIFICATE-----\n(skipped)\n-----END CERTIFICATE-----\n"
            },
            "kind": "ConfigMap",
            "metadata": {
                "annotations": {
                    "kubernetes.io/description": "Contains a CA bundle that can be used to verify the kube-apiserver when using internal endpoints such as the internal service IP or kubernetes.default.svc. No other usage is guaranteed across distributions of Kubernetes clusters."
                },
                "creationTimestamp": "2023-01-28T16:45:58Z",
                "name": "kube-root-ca.crt",
                "namespace": "default",
                "resourceVersion": "421",
                "uid": "4a2c9d5b-b192-4e6e-b825-7877782c7b0e"
            }
        },
        {
            "apiVersion": "v1",
            "data": {
                "nginx.conf": "server {\n    listen 80;\n    server_name  netology.ru www.netology.ru;\n    access_log  /var/log/nginx/domains/netology.ru-access.log  main;\n    error_log   /var/log/nginx/domains/netology.ru-error.log info;\n    location / {\n        include proxy_params;\n        proxy_pass http://10.10.10.10:8080/;\n    }\n}\n"
            },
            "kind": "ConfigMap",
            "metadata": {
                "creationTimestamp": "2023-01-28T20:22:05Z",
                "name": "nginx-config",
                "namespace": "default",
                "resourceVersion": "9891",
                "uid": "46a5e0f1-96aa-4880-9211-0e2e06594c63"
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": ""
    }
}
```
```bash
$ kubectl get configmap nginx-config -o yaml > nginx-config.yml

$ cat nginx-config.yml

apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2023-01-28T20:22:05Z"
  name: nginx-config
  namespace: default
  resourceVersion: "9891"
  uid: 46a5e0f1-96aa-4880-9211-0e2e06594c63
```

### Как удалить карту конфигурации?

Удалим карту конфигурации:
```
$ kubectl delete configmap nginx-config

configmap "nginx-config" deleted

$ kubectl get configmap nginx-config

Error from server (NotFound): configmaps "nginx-config" not found
```

### Как загрузить карту конфигурации из файла?

Восстановим карту конфигурации из ранее созданного файла `nginx-config.yml`:
```bash
$ kubectl apply -f nginx-config.yml

configmap/nginx-config created

$ kubectl get configmap nginx-config

NAME           DATA   AGE
nginx-config   1      14s
```

## Задача 2 (*): Работа с картами конфигураций внутри модуля

> Выбрать любимый образ контейнера, подключить карты конфигураций и проверить
> их доступность как в виде переменных окружения, так и в виде примонтированного
> тома

Подключим созданные в задаче 1 карты конфигурации в контейнер веб-сервера `nginx`. В файле манифеста [nginx.yml]() карту конфигурации `nginx-config` поключаем в виде файла, а карту конфигурации `domain` - как переменную окружения:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:  
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
      protocol: TCP
    volumeMounts:
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
    env:
      - name: NGINX_DOMAIN
        valueFrom:
          configMapKeyRef:
            name: domain
            key: name
            optional: false
  volumes:
  - name: config
    configMap:
      name: nginx-config
```

Запускаем под и проверяем, что в нём присутствует файл конфигурации и переменная окружения из карты конфигурации:
```bash
$ kubectl apply -f nginx.yml

pod/nginx created

$ kubectl exec nginx -- ls -l /etc/nginx/conf.d

total 0
lrwxrwxrwx 1 root root 17 Jan 28 21:42 nginx.conf -> ..data/nginx.conf

$ kubectl exec nginx -- cat /etc/nginx/conf.d/nginx.conf

server {
    listen 80;
    server_name  netology.ru www.netology.ru;
    access_log  /var/log/nginx/netology.ru-access.log  main;
    error_log   /var/log/nginx/netology.ru-error.log info;
    location / {
        proxy_pass http://10.10.10.10:8080/;
    }
}

$ kubectl exec nginx -- printenv NGINX_DOMAIN

example.com
```

Проверим, как ведут себя карты конфигураций внутри запущенного контейнера, если изменить их снаружи на другие. Для этого изменим содержимое обоих карт конфигураций. Для `nginx-config` исправим содержимое файла манифеста `nginx-config.yml` на следующее:
```yaml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  example.com www.example.com;
        access_log  /var/log/nginx/domains/example.com-access.log  main;
        error_log   /var/log/nginx/domains/example.com-error.log info;
        location / {
            proxy_pass http://10.10.10.10:8888/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2023-01-28T21:42:04Z"
  name: nginx-config
  namespace: default
  resourceVersion: "13361"
  uid: 328b23d5-a454-44cd-925d-5b76d3df37dc
```
Применим изменения, и проверим содержимое файла конфигурации в запущенном контейнере:
```bash
$ kubectl apply -f nginx-config.yml

Warning: resource configmaps/nginx-config is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/nginx-config configured

$ kubectl exec nginx -- cat /etc/nginx/conf.d/nginx.conf

server {
    listen 80;
    server_name  example.com www.example.com;
    access_log  /var/log/nginx/domains/example.com-access.log  main;
    error_log   /var/log/nginx/domains/example.com-error.log info;
    location / {
        proxy_pass http://10.10.10.10:8888/;
    }
}
```

Как видим, файл конфигурации внутри запущенного модуля автоматически изменился. Для применения изменений достаточно будет дать nginx команду для обновления конфигурации, и это не потребует перезапуска пода.

Для карты конфигурации, созданной из строки, изменения автоматически не передадутся, потому что в манифесте она используется для создания переменной окружения. Проверим это. Сначала сохраним манифест для карты конфигурации `domain`:
```bash
$ kubectl get configmap domain -o yaml > domain.yml
```
Модифицируем его, заменив содержимое на следующее   :
```yaml
apiVersion: v1
data:
  name: netology.ru
kind: ConfigMap
metadata:
  creationTimestamp: "2023-01-28T20:22:36Z"
  name: domain
  namespace: default
  resourceVersion: "9914"
  uid: 1fa8e31b-966f-4a0c-a822-6e6ab3d53a0c
```
и применим изменения:
```bash
$ kubectl apply -f domain.yml

Warning: resource configmaps/domain is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/domain configured

$ kubectl get configmap domain -o yaml

apiVersion: v1
data:
  name: netology.ru
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"name":"netology.ru"},"kind":"ConfigMap","metadata":{"annotations":{},"creationTimestamp":"2023-01-28T20:22:36Z","name":"domain","namespace":"default","resourceVersion":"9914","uid":"1fa8e31b-966f-4a0c-a822-6e6ab3d53a0c"}}
  creationTimestamp: "2023-01-28T20:22:36Z"
  name: domain
  namespace: default
  resourceVersion: "14008"
  uid: 1fa8e31b-966f-4a0c-a822-6e6ab3d53a0c
```

В запущенном контейнере значение переменной окружения не изменилось:
```bash
$ kubectl exec nginx -- printenv NGINX_DOMAIN

example.com
```
Таким образом, при передаче конфигурации через переменные окружения для их изменения необходимо рестартовать под.
