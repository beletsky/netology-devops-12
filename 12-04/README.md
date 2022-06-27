# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"

> Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
> Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
> * подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
> * в качестве CRI — containerd;
> * запуск etcd производить на мастере.

Развёртываем на Yandex.Cloud вирутальные машины, одну для Control Plane, и четыре для рабочих нод:
```bash
$ yc compute instance list

+----------------------+-------+---------------+---------+---------------+-------------+
|          ID          | NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+-------+---------------+---------+---------------+-------------+
| fhmd57foen9kdco5s0s5 | node2 | ru-central1-a | RUNNING | 51.250.88.143 | 10.128.0.15 |
| fhmfkesec1pso5aq3ee5 | node1 | ru-central1-a | RUNNING | 51.250.14.80  | 10.128.0.21 |
| fhmp085lutag0ns040hl | cp1   | ru-central1-a | RUNNING | 51.250.91.240 | 10.128.0.12 |
| fhmq6hkrp92qhi0nun4b | node3 | ru-central1-a | RUNNING | 51.250.91.59  | 10.128.0.26 |
| fhmto439fjh1dku1kqut | node4 | ru-central1-a | RUNNING | 51.250.79.135 | 10.128.0.7  |
+----------------------+-------+---------------+---------+---------------+-------------+
```

Создаём файл инвентаря по умолчанию: 
```bash
$ declare -a IPS=(51.250.91.240 51.250.88.143 51.250.14.80 51.250.91.59 51.250.79.135)

$ CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

DEBUG: Adding group all
DEBUG: Adding group kube_control_plane
DEBUG: Adding group kube_node
DEBUG: Adding group etcd
DEBUG: Adding group k8s_cluster
DEBUG: Adding group calico_rr
DEBUG: adding host node1 to group all
DEBUG: adding host node2 to group all
DEBUG: adding host node3 to group all
DEBUG: adding host node4 to group all
DEBUG: adding host node5 to group all
DEBUG: adding host node1 to group etcd
DEBUG: adding host node2 to group etcd
DEBUG: adding host node3 to group etcd
DEBUG: adding host node1 to group kube_control_plane
DEBUG: adding host node2 to group kube_control_plane
DEBUG: adding host node1 to group kube_node
DEBUG: adding host node2 to group kube_node
DEBUG: adding host node3 to group kube_node
DEBUG: adding host node4 to group kube_node
DEBUG: adding host node5 to group kube_node
```

Конфигурацию кластера вручную правим в [файле инвентаря hosts.yaml](kuberspray/inventory/mycluster/hosts.yaml) (в том числе -- расположение сервера etcd на Control Plane). Проверяем, что в качестве CRI используется `containerd` в [файле настроек](kuberspray/inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml). В этом же файле настроек включаем опцию:
```yaml
supplementary_addresses_in_ssl_keys: [51.250.91.240]
```
для возможности доступа к Conrtol Plane кластера инструментом kubeclt извне.

Разворачиваем кластер:
```bash
$ ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml

...
PLAY RECAP ********************************************************************************************************************************
cp                         : ok=755  changed=143  unreachable=0    failed=0    skipped=1317 rescued=0    ignored=9
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node1                      : ok=505  changed=92   unreachable=0    failed=0    skipped=790  rescued=0    ignored=2
node2                      : ok=505  changed=92   unreachable=0    failed=0    skipped=789  rescued=0    ignored=2
node3                      : ok=505  changed=92   unreachable=0    failed=0    skipped=789  rescued=0    ignored=2
node4                      : ok=505  changed=92   unreachable=0    failed=0    skipped=789  rescued=0    ignored=2

Sunday 19 June 2022  19:56:59 +0300 (0:00:00.150)       0:28:42.222 ***********
===============================================================================
download : download_container | Download image if required ------------------------------------------------------------------------ 70.11s
download : download_container | Download image if required ------------------------------------------------------------------------ 48.99s
kubernetes/preinstall : Install packages requirements ----------------------------------------------------------------------------- 46.26s
network_plugin/calico : Wait for calico kubeconfig to be created ------------------------------------------------------------------ 43.36s
kubernetes/control-plane : kubeadm | Initialize first master ---------------------------------------------------------------------- 39.68s
download : download_container | Download image if required ------------------------------------------------------------------------ 35.20s
download : download_container | Download image if required ------------------------------------------------------------------------ 33.37s
download : download_container | Download image if required ------------------------------------------------------------------------ 28.14s
download : download_file | Validate mirrors --------------------------------------------------------------------------------------- 26.14s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates ------------------------------------------------------------ 26.09s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ----------------------------------------------------------------------- 22.32s
kubernetes/kubeadm : Join to cluster ---------------------------------------------------------------------------------------------- 21.82s
download : download_container | Download image if required ------------------------------------------------------------------------ 20.65s
download : download_container | Download image if required ------------------------------------------------------------------------ 17.59s
download : download_container | Download image if required ------------------------------------------------------------------------ 16.30s
network_plugin/calico : Calico | Create calico manifests -------------------------------------------------------------------------- 16.03s
kubernetes/node : install | Copy kubelet binary from download dir ----------------------------------------------------------------- 14.97s
download : download_container | Download image if required ------------------------------------------------------------------------ 13.02s
network_plugin/calico : Calico | Copy calicoctl binary from download dir ---------------------------------------------------------- 12.30s
network_plugin/calico : Calico | Create ipamconfig resources ---------------------------------------------------------------------- 12.21s
```

Для тестирования созданного кластера при помощи локального kubectl переносим сертификаты доступа с Control Plane в [локальную конфигурацию](~/.kube/config). Вначале получаем их на удалённом сервере:
```bash
$ ssh yc-user@51.250.91.240
$ sudo cat /root/.kube/config

apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <CERTIFICATE-DATA>
    server: https://127.0.0.1:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: <CERTIFICATE-DATA>
    client-key-data: <KEY-DATA>
```

и после переноса в [локальную конфигурацию](~/.kube/config) проверяем:
```bash
$ kubectl config set-context yc

Context "yc" modified.

$ kubectl get nodes -A

NAME    STATUS   ROLES                  AGE   VERSION
cp      Ready    control-plane,master   21h   v1.23.7
node1   Ready    <none>                 21h   v1.23.7
node2   Ready    <none>                 21h   v1.23.7
node3   Ready    <none>                 21h   v1.23.7
node4   Ready    <none>                 21h   v1.23.7

$ kubectl create deploy nginx --image=nginx:latest --replicas=4

deployment.apps/nginx created

$ kubectl get pods -o wide

NAME                     READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
nginx-7c658794b9-6gt7l   1/1     Running   0          35s   10.233.105.1   node4   <none>           <none>
nginx-7c658794b9-d9szm   1/1     Running   0          35s   10.233.90.1    node1   <none>           <none>
nginx-7c658794b9-hc7f8   1/1     Running   0          35s   10.233.92.2    node3   <none>           <none>
nginx-7c658794b9-mhxm8   1/1     Running   0          35s   10.233.96.1    node2   <none>           <none>
```