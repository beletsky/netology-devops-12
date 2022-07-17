# Домашнее задание к занятию "13.2 разделы и монтирование"

В учебных целях в качестве контейнеров бэкэнда и фронтэнда будем использовать два контейнера `busybox`. Этого достаточно, чтобы проверить работоспособность концепции `volumes` в Kubernetes. Естественно, в реальном приложении нагрузка подов будет другой. 

> Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
> Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
> * установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
> * добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
> * установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner
> 
> В конце установки будет выдан пример создания PVC для этого сервера.

Вначале установим nfs provisioner при помощи Helm:
```bash
$ helm version

version.BuildInfo{Version:"v3.9.1", GitCommit:"a7c043acb5ff905c261cfdc923a35776ba5e66e4", GitTreeState:"clean", GoVersion:"go1.17.5"}

$ helm install nfs-server stable/nfs-server-provisioner
WARNING: This chart is deprecated
NAME: nfs-server
LAST DEPLOYED: Sun Jul 17 13:10:50 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
```
Теперь мы можем использовать storage class `nfs` для создания persistent volume.


## Задание 1: подключить для тестового конфига общую папку
> В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
> * в поде подключена общая папка между контейнерами (например, /static);
> * после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

Для тестового стенда контейнеры бэкэнда и фронтэнда располагаются внутри одного пода, поэтому для передачи информации между ними достаточно создать `volume` на основе `emptyDir`.

Пример такой конфигурации приведён в следующем [манифесте](dev/pod-with-common-volume.yaml).

Запустим его:
```bash
$ kubectl apply -f dev

pod/pod-with-common-volume created

$ kubectl get pod

NAME                     READY   STATUS    RESTARTS   AGE
pod-with-common-volume   2/2     Running   0          13s
```

Проверим, что созданный `volume` доступен одновременно из обоих контейнеров. Для этого, согласно заданию, создадим файл на бэкэнде, и проверим его наличие на фронтэнде:
```bash
$ kubectl exec -it pod-with-common-volume -c backend -- sh

/ # ls -la /static
total 8
drwxrwxrwx    2 root     root          4096 Jul 16 14:42 .
drwxr-xr-x    1 root     root          4096 Jul 16 14:42 ..

/ # echo "Test content." > /static/test.txt

/ # ls -la /static
total 12
drwxrwxrwx    2 root     root          4096 Jul 16 14:47 .
drwxr-xr-x    1 root     root          4096 Jul 16 14:42 ..
-rw-r--r--    1 root     root            13 Jul 16 14:47 test.txt

/ # exit
```
```bash
$ kubectl exec -it pod-with-common-volume -c frontend -- sh

/ # ls -la /public/content
total 12
drwxrwxrwx    2 root     root          4096 Jul 16 14:47 .
drwxr-xr-x    3 root     root          4096 Jul 16 14:43 ..
-rw-r--r--    1 root     root            13 Jul 16 14:47 test.txt

/ # cat /public/content/test.txt
Test content.

/ # echo "Another content." > /public/content/test.txt

/ # exit
```
```bash
$ kubectl exec -it pod-with-common-volume -c backend -- sh

/ # cat /static/test.txt
Another content.

/ # exit
```

Всё работает, как и ожидалось. Содержимое папки доступно и может быть изменено из обоих контейнеров в поде.


## Задание 2: подключить общую папку для прода
> Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
> * все бекенды подключаются к одному PV в режиме ReadWriteMany;
> * фронтенды тоже подключаются к этому же PV с таким же режимом;
> * файлы, созданные бекендом, должны быть доступны фронту.

Для production-окружения контейнеры бэкэнда и фронтэнда работают в разных подах (и даже на разных машинах), поэтому для создания общей папки потребуется использовать Persistent Volume. Согласно условию задачи, необходимо использовать dynamic provisioning и использовать для общей папки режим ReadWriteMany.

Создадим два отдельных пода для обоих компонентов приложения и Persistent Volume Claim со storage class `nfs`. Манифесты для данной конфигурации приведены в [папке](prod/).

После запуска данной конфигурации получаем:
```bash
$ kubectl apply -f prod

deployment.apps/backend created
deployment.apps/frontend created
persistentvolumeclaim/static-content created

$ kubectl get pod

NAME                                  READY   STATUS    RESTARTS   AGE
backend-78f8bdc4bf-hf868              1/1     Running   0          13s
frontend-d89d45954-fzwhp              1/1     Running   0          13s
nfs-server-nfs-server-provisioner-0   1/1     Running   0          4m2s

$ kubectl get pvc

NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
static-content   Bound    pvc-56a2caf0-01fd-4a69-9436-5194aef077cd   2Gi        RWX            nfs            68s

$ kubectl get pv

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
pvc-56a2caf0-01fd-4a69-9436-5194aef077cd   2Gi        RWX            Delete           Bound    default/static-content   nfs                     92s
```

Проверим работоспособность созданного persistent volume обычным образом:
```bash
$ kubectl exec -it backend-78f8bdc4bf-hf868 -- sh

/ # ls -la /static
total 8
drwxrwsrwx    2 root     root          4096 Jul 17 10:14 .
drwxr-xr-x    1 root     root          4096 Jul 17 10:14 ..

/ # echo "Test content." > /static/test.txt

/ # cat /static/test.txt
Test content.

/ # exit

$ kubectl exec -it frontend-d89d45954-fzwhp -- sh

/ # ls -la /public/content
total 12
drwxrwsrwx    2 root     root          4096 Jul 17 10:24 .
drwxr-xr-x    3 root     root          4096 Jul 17 10:14 ..
-rw-r--r--    1 root     root            14 Jul 17 10:24 test.txt

/ # cat /public/content/test.txt
Test content.

/ # echo "Another content." > /public/content/test.txt

/ # cat /public/content/test.txt
Another content.

/ # exit

$ kubectl exec -it backend-78f8bdc4bf-hf868 -- sh

/ # cat /static/test.txt
Another content.

/ # exit
```

Проверим, что данные на persistent volume сохраняются даже при выключении подов. Для этого вначале удалим deployments для бэкэнда и фронтэнда и убедимся, что persistent volume сохранился:

```bash
$ kubectl delete -f prod/backend.yaml

deployment.apps "backend" deleted

$ kubectl delete -f prod/frontend.yaml

deployment.apps "frontend" deleted

$ kubectl get pod

NAME                                  READY   STATUS    RESTARTS   AGE
nfs-server-nfs-server-provisioner-0   1/1     Running   0          20m

$ kubectl get pv

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
pvc-56a2caf0-01fd-4a69-9436-5194aef077cd   2Gi        RWX            Delete           Bound    default/static-content   nfs                     16m
```

Теперь снова запустим поды для бэкэнда и фронтэнда и проверим, что тестовый файл сохранился:

```bash
$ kubectl apply -f prod/backend.yaml

deployment.apps/backend created

$ kubectl apply -f prod/frontend.yaml

deployment.apps/frontend created

$ kubectl get pod

NAME                                  READY   STATUS    RESTARTS   AGE
backend-78f8bdc4bf-92ssz              1/1     Running   0          11s
frontend-d89d45954-k7frl              1/1     Running   0          7s
nfs-server-nfs-server-provisioner-0   1/1     Running   0          22m

$ kubectl exec -it backend-78f8bdc4bf-92ssz -- sh

/ # cat /static/test.txt
Another content.

/ # exit

$ kubectl exec -it frontend-d89d45954-k7frl -- sh

/ # cat /public/content/test.txt
Another content.

/ # exit
```

Наконец, проверим, что persistent volume нельзя удалить, пока запущены использующие его поды:

```bash
$ kubectl delete -f prod/static-content.yaml

persistentvolumeclaim "static-content" deleted
[PROCESS IS HANGING]
^C

$ kubectl get pvc

NAME             STATUS        VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
static-content   Terminating   pvc-56a2caf0-01fd-4a69-9436-5194aef077cd   2Gi        RWX            nfs            20m

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
pvc-56a2caf0-01fd-4a69-9436-5194aef077cd   2Gi        RWX            Delete           Bound    default/static-content   nfs                     21m
```

Persistent Volume Claim будет находиться в состоянии `Terminating` пока не будут удалены поды:

```bash
$ kubectl delete -f prod/backend.yaml

deployment.apps "backend" deleted

$ kubectl delete -f prod/frontend.yaml

deployment.apps "frontend" deleted

$ kubectl get pod

NAME                                  READY   STATUS        RESTARTS   AGE
backend-78f8bdc4bf-92ssz              1/1     Terminating   0          5m8s
frontend-d89d45954-k7frl              1/1     Terminating   0          5m4s
nfs-server-nfs-server-provisioner-0   1/1     Running       0          27m

$ kubectl get pod

NAME                                  READY   STATUS    RESTARTS   AGE
nfs-server-nfs-server-provisioner-0   1/1     Running   0          27m

$ kubectl get pvc

No resources found in default namespace.
```

Таким образом, всё работает как и ожидалось.