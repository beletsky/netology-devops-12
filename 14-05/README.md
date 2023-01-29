# Домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Для ознакомления с механизмом действия `security-context` создадим следущий манифест `security-context.yml`:
```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  containers:
  - name: security-context-demo
    image: fedora:latest
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "trap : TERM INT; sleep infinity & wait" ]
    securityContext:
      runAsUser: 1000
      runAsGroup: 3000
```

Запустим его:
```bash
$ kubectl apply -f secutiry-context.yml

pod/security-context-demo created
```

Убедимся, что внутри контейнера процессы работают от пользователя `1000:3000`:
```bash
$ kubectl exec security-context-demo -- id

uid=1000 gid=3000 groups=3000
```

Как видим, настройки `security-context` применились успешно.
