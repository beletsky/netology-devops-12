# Домашнее задание к занятию "13.3 работа с kubectl"

Для выполнения данного домашнего задания используем [конфигурацию для production, созданную в домашнем задании 13-01](../13-01/prod).

Разворачиваем данную конфигурацию:
```bash
$ kubectl apply -f ../13-01/prod

service/backend created
deployment.apps/backend created
service/db created
statefulset.apps/db created
service/frontend created
deployment.apps/frontend created

$ kubectl get pod

NAME                                  READY   STATUS    RESTARTS   AGE
backend-579559cddd-7bbtq              1/1     Running   0          4m15s
db-0                                  1/1     Running   0          4m15s
frontend-74c7bb8589-j5j2g             1/1     Running   0          4m15s
nfs-server-nfs-server-provisioner-0   1/1     Running   0          61m
```

## Задание 1: проверить работоспособность каждого компонента
> Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
> * сделайте запросы к бекенду;
> * сделайте запросы к фронту;
> * подключитесь к базе данных.

Проверим сначала функционирование сервисов при помощи создания port-forward к ним. Проверку для backend и frontend делаем точно так же, как и в [домашней работе 13-01](../13-01/README.md), открывая порты в одной консоли, и выполняя проверочные запросы в другой:
```bash
$ kubectl port-forward frontend-74c7bb8589-j5j2g 8000:80

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
$ kubectl port-forward backend-579559cddd-7bbtq 9000:9000

Forwarding from 127.0.0.1:9000 -> 9000
Forwarding from [::1]:9000 -> 9000
Handling connection for 9000
```
```bash
$ curl http://localhost:9000

{"detail":"Not Found"}
```
На моём локальном компьютере отсутствует клиент PostgreSQL, поэтому проверку доступа к БД сделаем при помощи команды telnet:
```bash
$ kubectl port-forward db-0 5432:5432
Forwarding from 127.0.0.1:5432 -> 5432
Forwarding from [::1]:5432 -> 5432
Handling connection for 5432
```
```bash
$ telnet localhost 5432
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
^]
telnet> quit
Connection closed.
```
Для чистоты эксперимента убедимся также, что без port-forwarding соединение не устанавливается:
```bash
$ telnet localhost 5432
Trying 127.0.0.1...
telnet: Unable to connect to remote host: Connection refused
```

Проверим теперь доступ к сервисам из соседних подов в том же namespace. Для этого создадим и запустим pod с образом `wbitt/network-multitool` при помощи [манифеста](multitool.yaml):
```bash
$ kubectl apply -f multitool.yaml

pod/multitool created

$ kubectl get pod -w

NAME                                  READY   STATUS    RESTARTS   AGE
backend-579559cddd-7bbtq              1/1     Running   0          54m
db-0                                  1/1     Running   0          54m
frontend-74c7bb8589-j5j2g             1/1     Running   0          54m
multitool                             1/1     Running   0          7s
nfs-server-nfs-server-provisioner-0   1/1     Running   0          110m
```
Зайдём в контейнер данного пода, и проверим доступность сервисов оттуда. Вначале проверим сетевую связность подов:
```bash
$ kubectl exec -it multitool -- bash

bash-5.1# ping frontend

PING frontend.default.svc.cluster.local (172.17.0.14) 56(84) bytes of data.
64 bytes from 172-17-0-14.frontend.default.svc.cluster.local (172.17.0.14): icmp_seq=1 ttl=64 time=0.966 ms
^C
--- frontend.default.svc.cluster.local ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 0.065/0.369/0.966/0.422 ms

bash-5.1# ping backend

PING backend.default.svc.cluster.local (172.17.0.10) 56(84) bytes of data.
64 bytes from 172-17-0-10.backend.default.svc.cluster.local (172.17.0.10): icmp_seq=1 ttl=64 time=3.88 ms
^C
--- backend.default.svc.cluster.local ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.884/3.884/3.884/0.000 ms

bash-5.1# ping db

PING db.default.svc.cluster.local (172.17.0.11) 56(84) bytes of data.
64 bytes from db-0.db.default.svc.cluster.local (172.17.0.11): icmp_seq=1 ttl=64 time=4.80 ms
^C
--- db.default.svc.cluster.local ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 4.801/4.801/4.801/0.000 ms
```

Затем проверим доступность сервисов:
```bash
bash-5.1# curl http://frontend

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

bash-5.1# curl http://backend:9000

{"detail":"Not Found"}

bash-5.1# telnet db 5432
Connected to db


Connection closed by foreign host
```
На всякий случай, снова убедимся, что доступов к другим портам подов нет:
```bash
bash-5.1# curl http://frontend:9000

curl: (7) Failed to connect to frontend port 9000 after 1 ms: Connection refused

bash-5.1# curl http://backend:80

curl: (7) Failed to connect to backend port 80 after 1 ms: Connection refused

bash-5.1# telnet db 2345

telnet: can't connect to remote host (172.17.0.11): Connection refused
```


## Задание 2: ручное масштабирование

> При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.

Убедимся вначале, что текущее количество копий сервисов -- по одному:
```bash
$ kubectl get pod -o wide
NAME                                  READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES
backend-579559cddd-7bbtq              1/1     Running   0          65m    172.17.0.10   minikube   <none>           <none>
db-0                                  1/1     Running   0          65m    172.17.0.11   minikube   <none>           <none>
frontend-74c7bb8589-j5j2g             1/1     Running   0          65m    172.17.0.14   minikube   <none>           <none>
multitool                             1/1     Running   0          11m    172.17.0.15   minikube   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          122m   172.17.0.6    minikube   <none>           <none>
```

Увеличиваем количество подов до 3:
```bash
$ kubectl scale --replicas=3 -f ../13-01/prod/backend.yaml

deployment.apps/backend scaled

$ kubectl scale --replicas=3 -f ../13-01/prod/frontend.yaml

deployment.apps/frontend scaled
```
Убеждаемся, что теперь запущено по три пода для каждого сервиса:
```bash
$ kubectl get pod -o wide
NAME                                  READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES
backend-579559cddd-2kjgc              1/1     Running   0          38s    172.17.0.16   minikube   <none>           <none>
backend-579559cddd-7bbtq              1/1     Running   0          68m    172.17.0.10   minikube   <none>           <none>
backend-579559cddd-jcpwn              1/1     Running   0          38s    172.17.0.17   minikube   <none>           <none>
db-0                                  1/1     Running   0          68m    172.17.0.11   minikube   <none>           <none>
frontend-74c7bb8589-47ztl             1/1     Running   0          7s     172.17.0.18   minikube   <none>           <none>
frontend-74c7bb8589-j5j2g             1/1     Running   0          68m    172.17.0.14   minikube   <none>           <none>
frontend-74c7bb8589-jfktq             1/1     Running   0          7s     172.17.0.19   minikube   <none>           <none>
multitool                             1/1     Running   0          14m    172.17.0.15   minikube   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          125m   172.17.0.6    minikube   <none>           <none>
```

Поскольку я использую minikube с одной working node, естественно, что все поды запущены на ней. В рабочей конфигурации, когда будет несколько working nodes, ожидается, что поды окажутся запущенными на разных нодах.

<details>
<summary>Приведем также полный вывод команды `kubectl describe pod`.</summary>

```bash
$ kubectl describe pod

Name:         backend-579559cddd-2kjgc
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 15:15:12 +0300
Labels:       app=backend
              pod-template-hash=579559cddd
Annotations:  <none>
Status:       Running
IP:           172.17.0.16
IPs:
  IP:           172.17.0.16
Controlled By:  ReplicaSet/backend-579559cddd
Init Containers:
  check-db-ready:
    Container ID:  docker://86ec56e601df38e961f369584e181e43d443b845a7036200cfd3197b3a35833d
    Image:         postgres:13-alpine
    Image ID:      docker-pullable://postgres@sha256:88b4d86d81a362b4a9b38cc8ed9766d2e4bfb98d731dda1542bead96982a866c
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until pg_isready -h db -p 5432; do echo waiting for database; sleep 2; done;
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Sun, 17 Jul 2022 15:15:14 +0300
      Finished:     Sun, 17 Jul 2022 15:15:14 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-clcpc (ro)
Containers:
  backend:
    Container ID:   docker://30a892ff27bf9c2f430f3b184c09054b9396a93c98497d7e201644dcb91e3683
    Image:          app_backend
    Image ID:       docker://sha256:c2174a6bcdcf1ff525bd6cff8332985b4ad06b7c52fae7c6d7d8d8f112a35047
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 17 Jul 2022 15:15:15 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-clcpc (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-clcpc:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m59s  default-scheduler  Successfully assigned default/backend-579559cddd-2kjgc to minikube
  Normal  Pulled     2m58s  kubelet            Container image "postgres:13-alpine" already present on machine
  Normal  Created    2m57s  kubelet            Created container check-db-ready
  Normal  Started    2m57s  kubelet            Started container check-db-ready
  Normal  Pulled     2m56s  kubelet            Container image "app_backend" already present on machine
  Normal  Created    2m56s  kubelet            Created container backend
  Normal  Started    2m56s  kubelet            Started container backend


Name:         backend-579559cddd-7bbtq
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 14:07:40 +0300
Labels:       app=backend
              pod-template-hash=579559cddd
Annotations:  <none>
Status:       Running
IP:           172.17.0.10
IPs:
  IP:           172.17.0.10
Controlled By:  ReplicaSet/backend-579559cddd
Init Containers:
  check-db-ready:
    Container ID:  docker://588bdbfd6d46062562f0fdf0483a69b8f48daf4696e2ca27ffef883ce0aa7655
    Image:         postgres:13-alpine
    Image ID:      docker-pullable://postgres@sha256:88b4d86d81a362b4a9b38cc8ed9766d2e4bfb98d731dda1542bead96982a866c
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until pg_isready -h db -p 5432; do echo waiting for database; sleep 2; done;
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Sun, 17 Jul 2022 14:07:43 +0300
      Finished:     Sun, 17 Jul 2022 14:08:18 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-t5j97 (ro)
Containers:
  backend:
    Container ID:   docker://638a9ddd3ed8531f737d89062001f7af2803c8027116abdb5ac6efea3aeedd84
    Image:          app_backend
    Image ID:       docker://sha256:c2174a6bcdcf1ff525bd6cff8332985b4ad06b7c52fae7c6d7d8d8f112a35047
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 17 Jul 2022 14:08:19 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-t5j97 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-t5j97:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>


Name:         backend-579559cddd-jcpwn
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 15:15:12 +0300
Labels:       app=backend
              pod-template-hash=579559cddd
Annotations:  <none>
Status:       Running
IP:           172.17.0.17
IPs:
  IP:           172.17.0.17
Controlled By:  ReplicaSet/backend-579559cddd
Init Containers:
  check-db-ready:
    Container ID:  docker://06cb6a55de77229bcde8de95803389f59c42ee75b914b4b3e1e00f383e3dfc82
    Image:         postgres:13-alpine
    Image ID:      docker-pullable://postgres@sha256:88b4d86d81a362b4a9b38cc8ed9766d2e4bfb98d731dda1542bead96982a866c
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until pg_isready -h db -p 5432; do echo waiting for database; sleep 2; done;
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Sun, 17 Jul 2022 15:15:14 +0300
      Finished:     Sun, 17 Jul 2022 15:15:14 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-gsbpx (ro)
Containers:
  backend:
    Container ID:   docker://5eebe214840b6f9d5551181ef17df324c1a831c060842f908c4997a4ff7af1be
    Image:          app_backend
    Image ID:       docker://sha256:c2174a6bcdcf1ff525bd6cff8332985b4ad06b7c52fae7c6d7d8d8f112a35047
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 17 Jul 2022 15:15:15 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-gsbpx (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-gsbpx:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m59s  default-scheduler  Successfully assigned default/backend-579559cddd-jcpwn to minikube
  Normal  Pulled     2m58s  kubelet            Container image "postgres:13-alpine" already present on machine
  Normal  Created    2m57s  kubelet            Created container check-db-ready
  Normal  Started    2m57s  kubelet            Started container check-db-ready
  Normal  Pulled     2m56s  kubelet            Container image "app_backend" already present on machine
  Normal  Created    2m56s  kubelet            Created container backend
  Normal  Started    2m56s  kubelet            Started container backend


Name:         db-0
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 14:07:40 +0300
Labels:       app=db
              controller-revision-hash=db-6d97bf69cc
              statefulset.kubernetes.io/pod-name=db-0
Annotations:  <none>
Status:       Running
IP:           172.17.0.11
IPs:
  IP:           172.17.0.11
Controlled By:  StatefulSet/db
Containers:
  db:
    Container ID:   docker://51c0fec57e329178152dde2c8036cd65dfe22f1333a46db2e0337d69733cce18
    Image:          postgres:13-alpine
    Image ID:       docker-pullable://postgres@sha256:88b4d86d81a362b4a9b38cc8ed9766d2e4bfb98d731dda1542bead96982a866c
    Port:           5432/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sun, 17 Jul 2022 14:07:43 +0300
    Ready:          True
    Restart Count:  0
    Environment:
      POSTGRES_PASSWORD:  postgres
      POSTGRES_USER:      postgres
      POSTGRES_DB:        news
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-bwjtw (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-bwjtw:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>


Name:         frontend-74c7bb8589-47ztl
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 15:15:43 +0300
Labels:       app=frontend
              pod-template-hash=74c7bb8589
Annotations:  <none>
Status:       Running
IP:           172.17.0.18
IPs:
  IP:           172.17.0.18
Controlled By:  ReplicaSet/frontend-74c7bb8589
Containers:
  frontend:
    Container ID:   docker://24571b1ffd7b5e2d2c83f22d884ae736509718ae93153d7ed30e897303cc5508
    Image:          app_frontend
    Image ID:       docker://sha256:5c46b6517959ecc5d346bc6e8996b4793e2c1b7dcd57c2952dc06b4d731d7407
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 17 Jul 2022 15:15:45 +0300
    Ready:          True
    Restart Count:  0
    Environment:
      BASE_URL:  http://backend:9000
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-t48zg (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-t48zg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m28s  default-scheduler  Successfully assigned default/frontend-74c7bb8589-47ztl to minikube
  Normal  Pulled     2m26s  kubelet            Container image "app_frontend" already present on machine
  Normal  Created    2m26s  kubelet            Created container frontend
  Normal  Started    2m26s  kubelet            Started container frontend


Name:         frontend-74c7bb8589-j5j2g
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 14:07:41 +0300
Labels:       app=frontend
              pod-template-hash=74c7bb8589
Annotations:  <none>
Status:       Running
IP:           172.17.0.14
IPs:
  IP:           172.17.0.14
Controlled By:  ReplicaSet/frontend-74c7bb8589
Containers:
  frontend:
    Container ID:   docker://cb0f3fae6b08a8847d69667a8ab626797d3b920d9cb70912e4168fbb89551f9f
    Image:          app_frontend
    Image ID:       docker://sha256:5c46b6517959ecc5d346bc6e8996b4793e2c1b7dcd57c2952dc06b4d731d7407
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 17 Jul 2022 14:07:43 +0300
    Ready:          True
    Restart Count:  0
    Environment:
      BASE_URL:  http://backend:9000
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-w8b6k (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-w8b6k:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>


Name:         frontend-74c7bb8589-jfktq
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 15:15:43 +0300
Labels:       app=frontend
              pod-template-hash=74c7bb8589
Annotations:  <none>
Status:       Running
IP:           172.17.0.19
IPs:
  IP:           172.17.0.19
Controlled By:  ReplicaSet/frontend-74c7bb8589
Containers:
  frontend:
    Container ID:   docker://91e63bba3b849c7bac14e6163560e2d97c5f7c347d80cc397db85a7e998753b9
    Image:          app_frontend
    Image ID:       docker://sha256:5c46b6517959ecc5d346bc6e8996b4793e2c1b7dcd57c2952dc06b4d731d7407
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 17 Jul 2022 15:15:45 +0300
    Ready:          True
    Restart Count:  0
    Environment:
      BASE_URL:  http://backend:9000
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-nk7kl (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-nk7kl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m28s  default-scheduler  Successfully assigned default/frontend-74c7bb8589-jfktq to minikube
  Normal  Pulled     2m26s  kubelet            Container image "app_frontend" already present on machine
  Normal  Created    2m26s  kubelet            Created container frontend
  Normal  Started    2m26s  kubelet            Started container frontend


Name:         multitool
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 15:01:39 +0300
Labels:       app=multitool
Annotations:  <none>
Status:       Running
IP:           172.17.0.15
IPs:
  IP:  172.17.0.15
Containers:
  network-multitool:
    Container ID:   docker://3e121aa1e472f0e9dcc3d1abe86527b3ed3a148e6afb923279cf1f687e59361b
    Image:          wbitt/network-multitool
    Image ID:       docker-pullable://wbitt/network-multitool@sha256:82a5ea955024390d6b438ce22ccc75c98b481bf00e57c13e9a9cc1458eb92652
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 17 Jul 2022 15:01:40 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-m2pb2 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-m2pb2:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  16m   default-scheduler  Successfully assigned default/multitool to minikube
  Normal  Pulled     16m   kubelet            Container image "wbitt/network-multitool" already present on machine
  Normal  Created    16m   kubelet            Created container network-multitool
  Normal  Started    16m   kubelet            Started container network-multitool


Name:         nfs-server-nfs-server-provisioner-0
Namespace:    default
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Sun, 17 Jul 2022 13:10:50 +0300
Labels:       app=nfs-server-provisioner
              chart=nfs-server-provisioner-1.1.3
              controller-revision-hash=nfs-server-nfs-server-provisioner-64bd6d7f65
              heritage=Helm
              release=nfs-server
              statefulset.kubernetes.io/pod-name=nfs-server-nfs-server-provisioner-0
Annotations:  <none>
Status:       Running
IP:           172.17.0.6
IPs:
  IP:           172.17.0.6
Controlled By:  StatefulSet/nfs-server-nfs-server-provisioner
Containers:
  nfs-server-provisioner:
    Container ID:  docker://cbee685fa2e6fae1ecdbd14beb39dede6e9c4e52ffedfabf3c0df288664045c2
    Image:         quay.io/kubernetes_incubator/nfs-provisioner:v2.3.0
    Image ID:      docker-pullable://quay.io/kubernetes_incubator/nfs-provisioner@sha256:f402e6039b3c1e60bf6596d283f3c470ffb0a1e169ceb8ce825e3218cd66c050
    Ports:         2049/TCP, 2049/UDP, 32803/TCP, 32803/UDP, 20048/TCP, 20048/UDP, 875/TCP, 875/UDP, 111/TCP, 111/UDP, 662/TCP, 662/UDP
    Host Ports:    0/TCP, 0/UDP, 0/TCP, 0/UDP, 0/TCP, 0/UDP, 0/TCP, 0/UDP, 0/TCP, 0/UDP, 0/TCP, 0/UDP
    Args:
      -provisioner=cluster.local/nfs-server-nfs-server-provisioner
    State:          Running
      Started:      Sun, 17 Jul 2022 13:11:21 +0300
    Ready:          True
    Restart Count:  0
    Environment:
      POD_IP:          (v1:status.podIP)
      SERVICE_NAME:   nfs-server-nfs-server-provisioner
      POD_NAMESPACE:  default (v1:metadata.namespace)
    Mounts:
      /export from data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-6xqcs (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  data:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  kube-api-access-6xqcs:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
```
</details>
Видим, что в кластере действительно запущено по три копии backend и frontend.

Наконец, снова уменьшим количество копий сервисов до 1:
```bash
$ kubectl scale --replicas=1 -f ../13-01/prod/backend.yaml

deployment.apps/backend scaled

$ kubectl scale --replicas=1 -f ../13-01/prod/frontend.yaml

deployment.apps/frontend scaled

$ kubectl get pod -o wide

NAME                                  READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES
backend-579559cddd-7bbtq              1/1     Running   0          75m    172.17.0.10   minikube   <none>           <none>
db-0                                  1/1     Running   0          75m    172.17.0.11   minikube   <none>           <none>
frontend-74c7bb8589-j5j2g             1/1     Running   0          75m    172.17.0.14   minikube   <none>           <none>
multitool                             1/1     Running   0          21m    172.17.0.15   minikube   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          132m   172.17.0.6    minikube   <none>           <none>
```
Отметим, что Kubernetes погасил те экземпляры подов, которые были созданы последними, оставив работать самые "ранние" экземпляры. Судя по [ответу на вопрос](https://stackoverflow.com/questions/60894641/after-a-scale-down-of-k8s-pod-replicas-how-does-k8s-choose-which-to-terminate) и коду Kubernetes, так как у меня всего одна working node, это закономерный результат.
