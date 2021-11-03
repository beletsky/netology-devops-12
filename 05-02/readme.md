# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Задача 1

> - Опишите своими словами основные преимущества применения на практике IaaC паттернов.
> - Какой из принципов IaaC является основополагающим?

Преимущества паттерна IaaC:

1. Устранение дрейфа конфигураций (как на машинах разработчиков, так и на серверах).
2. Упрощение тестирования и развёртывания.
3. Упрощение масштабирования.
4. Уменьшение Time-to-Marker.

Конечной целью большинства видов деятельности человека является извлечение прибыли, поэтому естественно, что основополагающим принципом IaaC является уменьшение Time-to-Market.  

## Задача 2

> - Чем Ansible выгодно отличается от других систем управление конфигурациями?
> - Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

Основное отличие Ansilbe от других систем управления конфигурациями состоит в том, что он не требует дополнительного программного обеспечения, устанавливаемого на клиентах. Для его работы необходима только возможность соединения с клиентом по SSH.

По моему опыту, pull обладают следующими недостатками:

1. Необходимость явного указания необходимости внесения изменений.
2. Сложность раскатывания конфигураций на большое количество узлов (из-за ограничений по количеству создаваемых соединений с единого узла управления и возможных задержках при соединениях).

С другой стороны, pull-системы имеют ряд преимуществ:

1. Полный контроль над моментом применения изменений.
2. Проще мониторить ход процесса обновления, можно быстрее остановить или откатить его при возникновении проблем.
3. Проще мониторить состояние управляемых систем в процессе развёртывания (так как момент обновления чётко известен).

Достоинства push-систем:

1. Проще создавать задачи периодического автоматического применения обновлений.
2. Меньшая нагрузка на раздающий сервер, так как запросы на обновления приходят асинхронно.
3. Сложнее контроль над процессами раскатывания обновлений на большие группы серверов.

Их же недостатки:

1. Сложно мониторить процесс обновления (если падает канал связи, обновления могут не применяться вообще, нужно дополнительно мониторить доступность узла и процесса обновления на нём).

В целом, сделать надёжной можно и ту, и другую систему, вопрос больше в решаемых задачах. Нужно сделать наиболее часто решаемые задачи проще в работе и мониторинге. Мониторинг потенциально проще сделать для pull-системы.

## Задача 3

> Установить на личный компьютер:
> 
> - VirtualBox
> - Vagrant
> - Ansible
> 
> *Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

```bash
$ virtualbox -h
Oracle VM VirtualBox VM Selector v6.1.26_Ubuntu
(C) 2005-2021 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
```
```bash
$ vagrant version
Installed Version: 2.2.6

Vagrant was unable to check for the latest version of Vagrant.
Please check manually at https://www.vagrantup.com
```
```bash
$ ansible --version
ansible [core 2.11.6] 
  config file = None
  configured module search path = ['/home/andrey/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.8/dist-packages/ansible
  ansible collection location = /home/andrey/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.8.10 (default, Sep 28 2021, 16:10:42) [GCC 9.3.0]
  jinja version = 3.0.2
  libyaml = True
```

## Задача 4 (*)

> Воспроизвести практическую часть лекции самостоятельно.
> 
> - Создать виртуальную машину.
> - Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
> ```
> docker ps
> ```

В практической части домашнего задания я запустил виртуализацию уровня ОС (контейнер docker) на паравиртуализации (Ubuntu 20.04 на Vagrant) внутри паравиртуализации (Ubuntu 20.04 на Hyper-V) на Windows-машине. Это, конечно, впечатляет, не скрою :-).

```bash
...

==> server1.netology: Running provisioner: ansible...
Vagrant has automatically selected the compatibility mode '2.0'
according to the Ansible version installed ([core 2.11.6] ).

Alternatively, the compatibility mode can be specified in your Vagrantfile:
https://www.vagrantup.com/docs/provisioning/ansible_common.html#compatibility_mode

    server1.netology: Running ansible-playbook...

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
changed: [server1.netology]

TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: If you are using a module and expect the file to exist on the remote, see the remote_src option
fatal: [server1.netology]: FAILED! => {"changed": false, "msg": "Could not find or access '~/.ssh/id_rsa.pub' on the Ansible Controller.\nIf you are using a module and expect the file to exist on the remote, see the remote_src option"}
...ignoring

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=git)
ok: [server1.netology] => (item=curl)

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1   
```
```bash
$ vagrant ssh
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed 03 Nov 2021 03:54:02 PM UTC

  System load:  0.1               Users logged in:          0
  Usage of /:   3.2% of 61.31GB   IPv4 address for docker0: 172.17.0.1
  Memory usage: 20%               IPv4 address for eth0:    10.0.2.15
  Swap usage:   0%                IPv4 address for eth1:    192.168.192.11
  Processes:    105


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Wed Nov  3 15:52:26 2021 from 10.0.2.2
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
```bash
vagrant@server1:~$ docker run -it ubuntu:20.04
Unable to find image 'ubuntu:20.04' locally
20.04: Pulling from library/ubuntu
7b1a6ab2e44d: Pull complete 
Digest: sha256:626ffe58f6e7566e00254b638eb7e0f3b11d4da9675088f4781a50ae288f3322
Status: Downloaded newer image for ubuntu:20.04
root@7e8492da268a:/# cat /etc/os-release 
NAME="Ubuntu"
VERSION="20.04.3 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.3 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
root@7e8492da268a:/# 
```