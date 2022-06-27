# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
> Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
> После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
> Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 
> 
> Требования:
>  * пример из hello world запущен в качестве deployment
>  * количество реплик в deployment установлено в 2
>  * наличие deployment можно проверить командой kubectl get deployment
>  * наличие подов можно проверить командой kubectl get pods

```bash
$ kubectl create namespace "app-namespace"

namespace/app-namespace created

$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --port=8080 --replicas=2 -n "app-namespace"

deployment.apps/hello-node created

$ kubectl get pods -n app-namespace

NAME                         READY   STATUS    RESTARTS   AGE
hello-node-75b6b97c8-8cpsz   1/1     Running   0          59s
hello-node-75b6b97c8-b6zwl   1/1     Running   0          59s
```


## Задание 2: Просмотр логов для разработки
> Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
> Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.
> 
> Требования: 
>  * создан новый токен доступа для пользователя
>  * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
>  * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

Вначале создадим аккаунт и роль, и привяжем аккаунт к роли.

```bash
$ kubectl create serviceaccount developer --namespace=app-namespace

serviceaccount/developer created

$ kubectl get serviceaccount developer -o yaml --namespace=app-namespace
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-06-05T22:46:16Z"
  name: developer
  namespace: app-namespace
  resourceVersion: "7497"
  uid: 65fc0aba-0e8c-410d-8204-1919b3603b9f
secrets:
- name: developer-token-kbnvd

$ kubectl create role role-read-only --verb=get,watch --resource=pods,pods/log --namespace=app-namespace

role.rbac.authorization.k8s.io/role-read-only created

$ kubectl get role role-read-only -o yaml --namespace=app-namespace

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: "2022-06-05T22:55:58Z"
  name: role-read-only
  namespace: app-namespace
  resourceVersion: "7984"
  uid: fabd9961-7e16-4106-8cf8-76fed4d2c629
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - pods/log
  verbs:
  - get
  - watch

$ kubectl create rolebinding binding-read-only --role=role-read-only --serviceaccount=app-namespace:developer --namespace=app-namespace

rolebinding.rbac.authorization.k8s.io/binding-read-only created

$ kubectl get rolebindings binding-read-only -o yaml --namespace=app-namespace

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2022-06-05T23:25:20Z"
  name: binding-read-only
  namespace: app-namespace
  resourceVersion: "9462"
  uid: 50ddb8ad-2e1d-4874-b067-5ca3828c5ab9
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: role-read-only
subjects:
- kind: ServiceAccount
  name: developer
  namespace: app-namespace
```

Добавляем в текущий контекст нового пользователя с токеном, соответствующим созданному выше ServiceAccount.

```bash
$ kubectl get secret developer-token-kbnvd -o yaml --namespace=app-namespace

apiVersion: v1
data:
  ca.crt:
    <hidden>  
  namespace: YXBwLW5hbWVzcGFjZQ==
  token: 
    <hidden>
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: developer
    kubernetes.io/service-account.uid: 65fc0aba-0e8c-410d-8204-1919b3603b9f
  creationTimestamp: "2022-06-05T22:46:16Z"
  name: developer-token-kbnvd
  namespace: app-namespace
  resourceVersion: "7496"
  uid: a22edc98-bf5e-4509-b73b-40c0d40f8a5f
type: kubernetes.io/service-account-token

$ echo "<base64 token data>" | base64 -d

<decoded token value is hidden>

$ kubectl config set-credentials developer --token="<decoded token value>"

User "developer" set.

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
- name: developer
  user:
    token: REDACTED
- name: docker-desktop
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: minikube
  user:
    client-certificate: /home/andrey/.minikube/profiles/minikube/client.crt
    client-key: /home/andrey/.minikube/profiles/minikube/client.key
```

Проверяем получившийся результат.

```bash
$ kubectl get pods --namespace=app-namespace

NAME                         READY   STATUS    RESTARTS   AGE
hello-node-75b6b97c8-8cpsz   1/1     Running   0          71m
hello-node-75b6b97c8-b6zwl   1/1     Running   0          71m

$ kubectl get pods --namespace=app-namespace --user=developer

Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:app-namespace:developer" cannot list resource "pods" in API group "" in the namespace "app-namespace"

$ kubectl logs hello-node-75b6b97c8-8cpsz --namespace=app-namespace --user=developer

<empty output because there are no log entries>

$ kubectl describe pod hello-node-75b6b97c8-8cpsz --namespace=app-namespace --user=developer

Name:         hello-node-75b6b97c8-8cpsz
Namespace:    app-namespace
Priority:     0
Node:         minikube/192.168.49.2
Start Time:   Mon, 06 Jun 2022 01:24:39 +0300
Labels:       app=hello-node
              pod-template-hash=75b6b97c8
Annotations:  <none>
Status:       Running
IP:           172.17.0.5
IPs:
  IP:           172.17.0.5
Controlled By:  ReplicaSet/hello-node-75b6b97c8
Containers:
  echoserver:
    Container ID:   docker://4cb9856c2bb6e7dd348f700e7b36dd75a20f1454d67935154736db6098475529
    Image:          k8s.gcr.io/echoserver:1.4
    Image ID:       docker-pullable://k8s.gcr.io/echoserver@sha256:5d99aa1120524c801bc8c1a7077e8f5ec122ba16b6dda1a5d3826057f67b9bcb
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 06 Jun 2022 01:24:40 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vx2c2 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-vx2c2:
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

$ kubectl describe pod hello-node-75b6b97c8-8cpsz --user=developer

Error from server (Forbidden): pods "hello-node-75b6b97c8-8cpsz" is forbidden: User "system:serviceaccount:app-namespace:developer" cannot get resource "pods" in API group "" in the namespace "default"
```

Без возможности получить список подов (которая не упомянута как разрешённое действие в условии задачи) возможность просмотра их логов и описания выглядит ущербной, так как идентификаторы подов могут меняться. Поэтому на практике лучше добавить в список разрешённых ещё и --verb=list.


## Задание 3: Изменение количества реплик 
> Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 
> 
> Требования:
>  * в deployment из задания 1 изменено количество реплик на 5
>  * проверить что все поды перешли в статус running (kubectl get pods)

```bash
$ kubectl get pods --namespace=app-namespace

NAME                         READY   STATUS    RESTARTS   AGE
hello-node-75b6b97c8-8cpsz   1/1     Running   0          76m
hello-node-75b6b97c8-b6zwl   1/1     Running   0          76m

$ kubectl scale --replicas=5 deployment/hello-node --namespace=app-namespace

deployment.apps/hello-node scaled

$ kubectl get pods --namespace=app-namespace

NAME                         READY   STATUS    RESTARTS   AGE
hello-node-75b6b97c8-8cpsz   1/1     Running   0          77m
hello-node-75b6b97c8-b6zwl   1/1     Running   0          77m
hello-node-75b6b97c8-qnzds   1/1     Running   0          5s
hello-node-75b6b97c8-rglbb   1/1     Running   0          5s
hello-node-75b6b97c8-wk7zs   1/1     Running   0          5s
```
