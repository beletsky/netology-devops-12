# Домашнее задание к занятию "12.1 Компоненты Kubernetes"

> Вы DevOps инженер в крупной компании с большим парком сервисов. Ваша задача — разворачивать эти продукты в корпоративном кластере. 

## Задача 1: Установить Minikube

> Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине Minikube.

Я установил minikube на своей рабочей машине внутри подсистемы WSL на Windows 10. В качестве системы виртуализации используется Docker Desktop, также работающий внутри WSL.

```bash
$ minikube version

minikube version: v1.23.2
commit: 0a0ad764652082477c00d51d2475284b5d39ceed

$ minikube status

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

```bash
$ kubectl get pods --namespace=kube-system

NAME                               READY   STATUS    RESTARTS      AGE
coredns-78fcd69978-b7gq4           1/1     Running   0             56m
etcd-minikube                      1/1     Running   0             56m
kube-apiserver-minikube            1/1     Running   0             56m
kube-controller-manager-minikube   1/1     Running   0             56m
kube-proxy-5g7q2                   1/1     Running   0             56m
kube-scheduler-minikube            1/1     Running   0             56m
storage-provisioner                1/1     Running   1 (55m ago)   56m
```


## Задача 2: Запуск Hello World
> После установки Minikube требуется его проверить. Для этого подойдет стандартное приложение hello world. А для доступа к нему потребуется ingress.
> 
> - развернуть через Minikube тестовое приложение по [туториалу](https://kubernetes.io/ru/docs/tutorials/hello-minikube/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-minikube)
> - установить аддоны ingress и dashboard

```bash
$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4

deployment.apps/hello-node created

$ kubectl get deployments

NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   0/1     1            0           11s

$ kubectl get deployments

NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           23s

$ kubectl get pods

NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-bfshw   1/1     Running   0          31s

$ kubectl get events

LAST SEEN   TYPE     REASON                    OBJECT                             MESSAGE
40s         Normal   Scheduled                 pod/hello-node-7567d9fdc9-bfshw    Successfully assigned default/hello-node-7567d9fdc9-bfshw to minikube
39s         Normal   Pulling                   pod/hello-node-7567d9fdc9-bfshw    Pulling image "k8s.gcr.io/echoserver:1.4"
27s         Normal   Pulled                    pod/hello-node-7567d9fdc9-bfshw    Successfully pulled image "k8s.gcr.io/echoserver:1.4" in 12.1423801s
26s         Normal   Created                   pod/hello-node-7567d9fdc9-bfshw    Created container echoserver
26s         Normal   Started                   pod/hello-node-7567d9fdc9-bfshw    Started container echoserver
40s         Normal   SuccessfulCreate          replicaset/hello-node-7567d9fdc9   Created pod: hello-node-7567d9fdc9-bfshw
40s         Normal   ScalingReplicaSet         deployment/hello-node              Scaled up replica set hello-node-7567d9fdc9 to 1
59m         Normal   NodeHasSufficientMemory   node/minikube                      Node minikube status is now: NodeHasSufficientMemory
59m         Normal   NodeHasNoDiskPressure     node/minikube                      Node minikube status is now: NodeHasNoDiskPressure
59m         Normal   NodeHasSufficientPID      node/minikube                      Node minikube status is now: NodeHasSufficientPID
59m         Normal   Starting                  node/minikube                      Starting kubelet.
59m         Normal   NodeHasSufficientMemory   node/minikube                      Node minikube status is now: NodeHasSufficientMemory
59m         Normal   NodeHasNoDiskPressure     node/minikube                      Node minikube status is now: NodeHasNoDiskPressure
59m         Normal   NodeHasSufficientPID      node/minikube                      Node minikube status is now: NodeHasSufficientPID
59m         Normal   NodeNotReady              node/minikube                      Node minikube status is now: NodeNotReady
59m         Normal   NodeAllocatableEnforced   node/minikube                      Updated Node Allocatable limit across pods
58m         Normal   NodeReady                 node/minikube                      Node minikube status is now: NodeReady
58m         Normal   RegisteredNode            node/minikube                      Node minikube event: Registered Node minikube in Controller

$ kubectl config view

apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://kubernetes.docker.internal:6443
  name: docker-desktop
- cluster:
    certificate-authority: /home/andrey/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Sun, 05 Jun 2022 23:32:59 MSK
        provider: minikube.sigs.k8s.io
        version: v1.23.2
      name: cluster_info
    server: https://127.0.0.1:54868
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Sun, 05 Jun 2022 23:32:59 MSK
        provider: minikube.sigs.k8s.io
        version: v1.23.2
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: docker-desktop
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: minikube
  user:
    client-certificate: /home/andrey/.minikube/profiles/minikube/client.crt
    client-key: /home/andrey/.minikube/profiles/minikube/client.key
```

```bash
$ minikube addons enable dashboard

    ▪ Using image kubernetesui/dashboard:v2.3.1
    ▪ Using image kubernetesui/metrics-scraper:v1.0.7
💡  Some dashboard features require the metrics-server addon. To enable all features please run:

        minikube addons enable metrics-server


🌟  The 'dashboard' addon is enabled

$ minikube addons enable ingress

    ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.0
    ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.0
    ▪ Using image k8s.gcr.io/ingress-nginx/controller:v1.0.0-beta.3
🔎  Verifying ingress addon...
🌟  The 'ingress' addon is enabled

$ minikube addons list

|-----------------------------|----------|--------------|-----------------------|
|         ADDON NAME          | PROFILE  |    STATUS    |      MAINTAINER       |
|-----------------------------|----------|--------------|-----------------------|
...
...
| dashboard                   | minikube | enabled ✅   | kubernetes            |
...
...
| ingress                     | minikube | enabled ✅   | unknown (third-party) |
...
...
|-----------------------------|----------|--------------|-----------------------|
```


## Задача 3: Установить kubectl

> Подготовить рабочую машину для управления корпоративным кластером. Установить клиентское приложение kubectl.
> - подключиться к minikube 
> - проверить работу приложения из задания 2, запустив port-forward до кластера

```bash
$ kubectl config get-contexts

CURRENT   NAME           CLUSTER        AUTHINFO   NAMESPACE
*         minikube       minikube       minikube   default
```

```bash
$ kubectl expose deployment hello-node --type=NodePort --port=8080

service/hello-node exposed

$ kubectl get services

NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-node   NodePort    10.99.91.115   <none>        8080:30935/TCP   6s
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP          72m

$ minikube service hello-node --url

🏃  Starting tunnel for service hello-node.
|-----------|------------|-------------|------------------------|
| NAMESPACE |    NAME    | TARGET PORT |          URL           |
|-----------|------------|-------------|------------------------|
| default   | hello-node |             | http://127.0.0.1:42715 |
|-----------|------------|-------------|------------------------|
http://127.0.0.1:42715
❗  Because you are using a Docker driver on linux, the terminal needs to be open to run it.
```

Тест сервиса в другом окне терминала:

```bash
$ curl http://127.0.0.1:42715
CLIENT VALUES:
client_address=172.17.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://127.0.0.1:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=127.0.0.1:42715
user-agent=curl/7.68.0
BODY:
-no body in request-
```
