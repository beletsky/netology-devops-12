# Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

## Задача 1: Работа с модулем Vault

## Задача 2 (*): Работа с секретами внутри модуля

> * На основе образа fedora создать модуль;
> * Создать секрет, в котором будет указан токен;
> * Подключить секрет к модулю;
> * Запустить модуль и проверить доступность сервиса Vault.

Далее я выполню задачи 1 и 2 вместе, поскольку на практике подход задачи 1 неприменим (URL и токен указан в коде скрипта, внутри пода вручную выполняются команды).

Запускаем модуль Vault на основе манифеста [vault-pod.yml]:
```bash
$ kubectl apply -f vault-pod.yml

pod/14.2-netology-vault created

$ kubectl get pods

NAME                 READY   STATUS    RESTARTS   AGE
14.2-netology-vault  1/1     Running   0          46s
```

Доступ к Vault будем получать по внутреннему ip пода. Узнаем его:
```bash
$ kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'

[{"ip":"172.17.0.4"}]
```

Для работы с модулем Vault запустим под с дистрибутивом ОС Fedora, и выполним в нём скрипт на Python, который при помощи библиотеки `hvac` обратится к Vault и сначала создаст, а затем прочитает тестовый секрет.

URL, на котором расположен Vault, и значение токена для доступа к нему вынесем в секреты:
```bash
$ kubectl create secret generic vault --from-literal=url=http://172.17.0.4:8200 --from-literal=token="sdafjkl234782546@#$%klgdser7890"

secret/vault created
```

Под создаём на основе следующего манифеста [fedora.yml](), в который помещаем секреты и каталог со скриптом:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fedora
spec:
  containers:  
  - name: fedora
    image: fedora:latest
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "dnf -y install pip && pip install hvac && python3 /app/vault-test.py" ]
    volumeMounts:
    - name: app
      mountPath: /app
    env:
      - name: VAULT_URL
        valueFrom:
          secretKeyRef:
            name: vault
            key: url
            optional: false
      - name: VAULT_TOKEN
        valueFrom:
          secretKeyRef:
            name: vault
            key: token
            optional: false
  volumes:
  - name: app
    hostPath:
      path: /netology/14-02/app
```

Скрипт для записи и чтения секретов в Vault [app/vault-test.py]():
```python
import hvac
import os
import sys

try:
    client = hvac.Client(url=os.environ['VAULT_URL'], token=os.environ['VAULT_TOKEN'])
except KeyError:
    print("Environment variables VAULT_URL and VAULT_TOKEN should be set.")
    sys.exit(1)

if not client.is_authenticated():
    print("Vault authentication failed.")
    sys.exit(1)

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path = 'hvac',
    secret = dict(netology = 'Netology secret value in Vault.'),
)

# Читаем секрет
secret = client.secrets.kv.v2.read_secret_version(
    path = 'hvac',
)

print('The secret value is:')
print(secret['data']['data']['netology'])
```

Запускаем под и наблюдаем логи:
```bash
$ kubectl apply -f fedora.yml

pod/fedora created

$ kubectl logs fedora -f
...
...
Successfully installed certifi-2022.12.7 charset-normalizer-3.0.1 hvac-1.0.2 idna-3.4 pyhcl-0.4.4 requests-2.28.2 urllib3-1.26.14
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
The secret value is:
Netology secret value in Vault.
[Ctrl-C]
```
