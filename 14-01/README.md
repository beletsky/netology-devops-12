# Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

> Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
> задачу 1 как справочный материал.


### Как создать секрет?

В качестве примера секрета создадим приватный ключ RSA и самоподписанный сертификат SSL для подключения в `nginx` для поддержки протокола HTTPS. 

Создаём приватный RSA ключ:
```bash
$ openssl genrsa -out cert.key 4096

Generating RSA private key, 4096 bit long modulus (2 primes)
............................................................................................................................................................++++
.....................................++++
e is 65537 (0x010001)

$ ls -la cert.key

-rw------- 1 andrey andrey 3243 Jan 28 15:44 cert.key

$ cat cert.key
-----BEGIN RSA PRIVATE KEY-----
(skipped)
-----END RSA PRIVATE KEY-----
```

Создаём самоподписанный сертификат:
```bash
$ openssl req -x509 -new -key cert.key -days 3650 -out cert.crt -subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'

$ ls -la cert.crt

-rw-r--r-- 1 andrey andrey 1944 Jan 28 15:45 cert.crt

$ cat cert.crt

-----BEGIN CERTIFICATE-----
(skipped)
-----END CERTIFICATE-----
```

Создаём секрет с типом `tls` с именем `domain-cert`:
```bash
$ kubectl create secret tls domain-cert --cert=cert.crt --key=cert.key

secret/domain-cert created
```


### Как просмотреть список секретов?

Убедимся, что секрет добавился успешно:
```bash
$ kubectl get secrets

NAME                                            TYPE                                  DATA   AGE
default-token-zbphl                             kubernetes.io/service-account-token   3      236d
domain-cert                                     kubernetes.io/tls                     2      2m10s
nfs-server-nfs-server-provisioner-token-mn6rf   kubernetes.io/service-account-token   3      195d
sh.helm.release.v1.app1.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.app2.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.app3.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.nfs-server.v1                helm.sh/release.v1                    1      195d
```

Можно использовать сокращенное наименование ресурса (`secret`):
```bash
$ kubectl get secret

NAME                                            TYPE                                  DATA   AGE
default-token-zbphl                             kubernetes.io/service-account-token   3      236d
domain-cert                                     kubernetes.io/tls                     2      2m10s
nfs-server-nfs-server-provisioner-token-mn6rf   kubernetes.io/service-account-token   3      195d
sh.helm.release.v1.app1.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.app2.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.app3.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.nfs-server.v1                helm.sh/release.v1                    1      195d
```


### Как просмотреть секрет?

Для просмотра информации только о нашем секрете выполняем:
```bash
$ kubectl get secret domain-cert

NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      7m26s
```

Подробную информацию о секрете можно получить при помощи команды `describe`:
```bash
$ kubectl describe secret domain-cert

Name:         domain-cert
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1944 bytes
tls.key:  3243 bytes
```
Как видим, собственно содержимого секрета не выводится.


### Как получить информацию в формате YAML и/или JSON?

Полное содержимое секрета можно получить в формате `yaml`:
```bash
$ kubectl get secret domain-cert -o yaml

apiVersion: v1
data:
  tls.crt: (skipped)
  tls.key: (skipped)
kind: Secret
metadata:
  creationTimestamp: "2023-01-28T13:03:53Z"
  name: domain-cert
  namespace: default
  resourceVersion: "1116149"
  uid: 7ab3aa7e-b5f9-4070-b199-e2e3381e0b51
type: kubernetes.io/tls
```
или в формате `json`:
```bash
$ kubectl get secret domain-cert -o json

{
    "apiVersion": "v1",
    "data": {
        "tls.crt": "(skipped)",
        "tls.key": "(skipped)"
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2023-01-28T13:03:53Z",
        "name": "domain-cert",
        "namespace": "default",
        "resourceVersion": "1116149",
        "uid": "7ab3aa7e-b5f9-4070-b199-e2e3381e0b51"
    },
    "type": "kubernetes.io/tls"
}
```


### Как выгрузить секрет и сохранить его в файл?

Чтобы записать содержимое секретов в файл, используем обычную переадресацию вывода.

При желании можно получить содержимое сразу всех секретов:
```bash
$ kubectl get secrets -o json > secrets.json

$ cat secrets.json

{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "ca.crt": "(skipped)",
                "namespace": "ZGVmYXVsdA==",
                "token": "(skipped)"
            },
            "kind": "Secret",
            "metadata": {
                "annotations": {
                    "kubernetes.io/service-account.name": "default",
                    "kubernetes.io/service-account.uid": "1f96e27b-e255-45be-bf8b-e2489546acf8"
                },
                "creationTimestamp": "2022-06-05T20:33:11Z",
                "name": "default-token-zbphl",
                "namespace": "default",
                "resourceVersion": "429",
                "uid": "10819772-0d80-45b5-adaa-0e2f141f2dbe"
            },
            "type": "kubernetes.io/service-account-token"
        },
        {
            "apiVersion": "v1",
            "data": {
                "tls.crt": "(skipped)",
                "tls.key": "(skipped)"
            },
            "kind": "Secret",
            "metadata": {
                "creationTimestamp": "2023-01-28T13:03:53Z",
                "name": "domain-cert",
                "namespace": "default",
                "resourceVersion": "1116149",
                "uid": "7ab3aa7e-b5f9-4070-b199-e2e3381e0b51"
            },
            "type": "kubernetes.io/tls"
        },
        {
            "apiVersion": "v1",
            "data": {
                "ca.crt": "(skipped)",
                "namespace": "ZGVmYXVsdA==",
                "token": "(skipped)"
            },
            "kind": "Secret",
            "metadata": {
                "annotations": {
                    "kubernetes.io/service-account.name": "nfs-server-nfs-server-provisioner",
                    "kubernetes.io/service-account.uid": "f1830458-88cb-4f8f-8f37-11d4f1fe8b44"
                },
                "creationTimestamp": "2022-07-17T10:10:50Z",
                "name": "nfs-server-nfs-server-provisioner-token-mn6rf",
                "namespace": "default",
                "resourceVersion": "311321",
                "uid": "cdd3166a-a94d-4ac1-9318-c2a759e1c734"
            },
            "type": "kubernetes.io/service-account-token"
        },
        {
            "apiVersion": "v1",
            "data": {
                "release": "(skipped)"
            },
            "kind": "Secret",
            "metadata": {
                "creationTimestamp": "2022-07-24T00:44:21Z",
                "labels": {
                    "modifiedAt": "1658623461",
                    "name": "app1",
                    "owner": "helm",
                    "status": "deployed",
                    "version": "1"
                },
                "name": "sh.helm.release.v1.app1.v1",
                "namespace": "default",
                "resourceVersion": "745999",
                "uid": "685490ed-3a57-4603-9173-3b461031f2a2"
            },
            "type": "helm.sh/release.v1"
        },
        {
            "apiVersion": "v1",
            "data": {
                "release": "(skipped)"
            },
            "kind": "Secret",
            "metadata": {
                "creationTimestamp": "2022-07-24T00:50:10Z",
                "labels": {
                    "modifiedAt": "1658623810",
                    "name": "app2",
                    "owner": "helm",
                    "status": "deployed",
                    "version": "1"
                },
                "name": "sh.helm.release.v1.app2.v1",
                "namespace": "default",
                "resourceVersion": "746766",
                "uid": "c7b90b18-b0b3-4822-8cd5-1722998fc212"
            },
            "type": "helm.sh/release.v1"
        },
        {
            "apiVersion": "v1",
            "data": {
                "release": "(skipped)"
            },
            "kind": "Secret",
            "metadata": {
                "creationTimestamp": "2022-07-24T00:51:21Z",
                "labels": {
                    "modifiedAt": "1658623881",
                    "name": "app3",
                    "owner": "helm",
                    "status": "deployed",
                    "version": "1"
                },
                "name": "sh.helm.release.v1.app3.v1",
                "namespace": "default",
                "resourceVersion": "746940",
                "uid": "d888b0e5-70f5-4aa8-8e1c-07ee1364f9a6"
            },
            "type": "helm.sh/release.v1"
        },
        {
            "apiVersion": "v1",
            "data": {
                "release": "(skipped)"
            },
            "kind": "Secret",
            "metadata": {
                "creationTimestamp": "2022-07-17T10:10:50Z",
                "labels": {
                    "modifiedAt": "1658052650",
                    "name": "nfs-server",
                    "owner": "helm",
                    "status": "deployed",
                    "version": "1"
                },
                "name": "sh.helm.release.v1.nfs-server.v1",
                "namespace": "default",
                "resourceVersion": "311326",
                "uid": "57d6758b-1a9e-43fd-95b5-af0c0093c840"
            },
            "type": "helm.sh/release.v1"
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": ""
    }
}
```
или только одного из них:
```bash
$ kubectl get secret domain-cert -o yaml > domain-cert.yml

$ cat domain-cert.yml

apiVersion: v1
data:
  tls.crt: (skipped)
  tls.key: (skipped)
kind: Secret
metadata:
  creationTimestamp: "2023-01-28T13:03:53Z"
  name: domain-cert
  namespace: default
  resourceVersion: "1116149"
  uid: 7ab3aa7e-b5f9-4070-b199-e2e3381e0b51
type: kubernetes.io/tls
```

### Как удалить секрет?

Удалим секрет и убедимся, что он действительно отсутствует в списке:
```bash
$ kubectl delete secret domain-cert

secret "domain-cert" deleted

$ kubectl get secrets

NAME                                            TYPE                                  DATA   AGE
default-token-zbphl                             kubernetes.io/service-account-token   3      236d
nfs-server-nfs-server-provisioner-token-mn6rf   kubernetes.io/service-account-token   3      195d
sh.helm.release.v1.app1.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.app2.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.app3.v1                      helm.sh/release.v1                    1      188d
sh.helm.release.v1.nfs-server.v1                helm.sh/release.v1                    1      195d

$ kubectl get secret domain-cert

Error from server (NotFound): secrets "domain-cert" not found
```

### Как загрузить секрет из файла?

Восстановим секрет из файла, в который мы его сохранили раньше:
```bash
$ kubectl apply -f domain-cert.yml

secret/domain-cert created

$ kubectl get secret domain-cert

NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      21s
```


## Задача 2 (*): Работа с секретами внутри модуля

> Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
> как в виде переменных окружения, так и в виде примонтированного тома.

Подключим созданный секрет в pod, содержащий веб-сервер `nginx`. Для этого создадим следующий манифест `nginx.yaml`:
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
    - containerPort: 443
      protocol: TCP
    volumeMounts:
    - name: certs
      mountPath: "/etc/nginx/ssl"
      readOnly: true
  volumes:
  - name: certs
    secret:
      secretName: domain-cert
```

Запустим его и проверим, что файлы секретов были примонтированы:
```bash
$ kubectl get pods

NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          3m39s

$ kubectl exec nginx -- ls -l /etc/nginx/ssl

total 0
lrwxrwxrwx 1 root root 14 Jan 28 14:07 tls.crt -> ..data/tls.crt
lrwxrwxrwx 1 root root 14 Jan 28 14:07 tls.key -> ..data/tls.key

$ kubectl exec nginx -- cat /etc/nginx/ssl/tls.key

-----BEGIN RSA PRIVATE KEY-----
(skipped)
-----END RSA PRIVATE KEY-----

$ kubectl exec nginx -- cat /etc/nginx/ssl/tls.crt

-----BEGIN CERTIFICATE-----
(skipped)
-----END CERTIFICATE-----
```

Для практики, создадим ещё один секрет типа `generic` и подключим его в качестве переменной окружения.

Создаем секрет и проверяем, что он появился:
```bash
$ kubectl create secret generic upstream --from-literal=nginx_upstream=http://example.com

secret/upstream created

$ kubectl get secret upstream -o yaml

apiVersion: v1
data:
  nginx_upstream: aHR0cDovL2V4YW1wbGUuY29t
kind: Secret
metadata:
  creationTimestamp: "2023-01-28T14:18:04Z"
  name: upstream
  namespace: default
  resourceVersion: "1122062"
  uid: 7d089836-929e-4107-8288-0cbc64c1887e
type: Opaque
```

Для подключения секрета модифицируем манифест `nginx.yaml`:
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
    - containerPort: 443
      protocol: TCP
    volumeMounts:
    - name: certs
      mountPath: "/etc/nginx/ssl"
      readOnly: true
    env:
      - name: NGINX_UPSTREAM
        valueFrom:
          secretKeyRef:
            name: upstream
            key: nginx_upstream
            optional: false
  volumes:
  - name: certs
    secret:
      secretName: domain-cert
```
и перезапускаем под:
```bash
$ kubectl delete pod nginx

pod "nginx" deleted

$ kubectl apply -f nginx.yaml

pod/nginx created

$ kubectl get pods

NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          34s
```

Проверяем, что секрет доступен внутри пода как переменная окружения:
```bash
$ kubectl exec nginx -- printenv NGINX_UPSTREAM

http://example.com
```
