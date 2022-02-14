# Основная часть

> 1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

```bash
$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] ***********************************************************************************************************************
TASK [Gathering Facts] **********************************************************************************************************************
ok: [localhost]

TASK [Print OS] *****************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************
ok: [localhost] => {
    "msg": "12"
}

PLAY RECAP **********************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

Новое содержимое файла [group_vars/all/examp.yml](group_vars/all/examp.yml):
```yaml
---
  some_fact: all default fact
```

```bash
$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] ***********************************************************************************************************************
TASK [Gathering Facts] **********************************************************************************************************************
ok: [localhost]

TASK [Print OS] *****************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP **********************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

```bash
$ docker run --name centos7 --rm -d pycontribs/centos:7 sleep 9999999999
Unable to find image 'pycontribs/centos:7' locally
7: Pulling from pycontribs/centos
2d473b07cdd5: Already exists
43e1b1841fcc: Pull complete
85bf99ab446d: Pull complete
Digest: sha256:b3ce994016fd728998f8ebca21eb89bf4e88dbc01ec2603c04cc9c56ca964c69
Status: Downloaded newer image for pycontribs/centos:7
33cdea71fa15c1c32ddb32c8964c400f6d9e8cd6c097e68a29c0c9fa3bbb18bf

$ docker run --name elk --rm -d pycontribs/ubuntu sleep 9999999999
Unable to find image 'pycontribs/ubuntu:latest' locally
latest: Pulling from pycontribs/ubuntu
423ae2b273f4: Pull complete
de83a2304fa1: Pull complete
f9a83bce3af0: Pull complete
b6b53be908de: Pull complete
7378af08dad3: Pull complete
Digest: sha256:dcb590e80d10d1b55bd3d00aadf32de8c413531d5cc4d72d0849d43f45cb7ec4
Status: Downloaded newer image for pycontribs/ubuntu:latest
5d153eb3293635355743644b795ace77f4dd5f8a7323bdf49d461c062e767fed
```

> 4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml
PLAY [Print os facts] ***********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************
ok: [ubuntu] => {
    "msg": "deb"
}
ok: [centos7] => {
    "msg": "el"
}

PLAY RECAP **********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

Новое содержимое файла [group_vars/deb/examp.yml](group_vars/deb/examp.yml):
```yaml
---
  some_fact: deb default fact
```

Новое содержимое файла [group_vars/el/examp.yml](group_vars/el/examp.yml):
```yaml
---
  some_fact: el default fact
```

> 6. Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml
PLAY [Print os facts] ***********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}

PLAY RECAP **********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```bash
$ ansible-vault encrypt group_vars/deb/examp.yml
New Vault password: [netology]

$ ansible-vault encrypt group_vars/el/examp.yml
New Vault password: [netology]
```

> 8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

```bash
$ ansible-playbook --ask-vault-password -i inventory/prod.yml site.yml
Vault password: [netology]

PLAY [Print os facts] ***********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}

PLAY RECAP **********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

```bash
$ ansible-doc -t connection --list
community.docker.docker     Run tasks in docker containers
community.docker.docker_api Run tasks in docker containers
community.docker.nsenter    execute on host running controller container
local                       execute on controller
paramiko_ssh                Run tasks via python ssh (paramiko)
psrp                        Run tasks over Microsoft PowerShell Remoting Protocol
ssh                         connect via SSH client binary
winrm                       Run tasks over Microsoft's WinRM
```

> 10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

Новое содержимое файла [inventory/prod.yml](inventory/prod.yml):
```yaml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
  ```

> 11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

```bash
$ ansible-playbook --ask-vault-password -i inventory/prod.yml site.yml
Vault password: [netology]

PLAY [Print os facts] ***********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}

PLAY RECAP **********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> 12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

[https://github.com/beletsky/netology-devops-12/tree/master/08-01](https://github.com/beletsky/netology-devops-12/tree/master/08-01).

# Самоконтроль выполнения задания

> 1. Где расположен файл с `some_fact` из второго пункта задания?

Файл [`group_vars/all/exampl.yml`](group_vars/all/examp.yml), строка `2`.

> 2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

```bash
ansible-playbook -i inventory/test.yml site.yml
```

> 3. Какой командой можно зашифровать файл?

```bash
ansible-vault encrypt group_vars/deb/examp.yml
```

> 4. Какой командой можно расшифровать файл?

```bash
ansible-vault decrypt group_vars/deb/examp.yml
```

> 5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

```bash
ansible-vault view group_vars/deb/examp.yml
```

> 6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

```bash
ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml
ansible-playbook --vault-password-file passwords -i inventory/prod.yml site.yml
```

> 7. Как называется модуль подключения к host на windows?

```bash
winrm                       Run tasks over Microsoft's WinRM
```

> 8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

```bash
ansible-doc -t connection ssh
```

> 9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

```bash
- remote_user
        User name with which to login to the remote server, normally
        set by the remote_user keyword.
        If no user is supplied, Ansible will let the SSH client binary
        choose the user as it normally.
        [Default: (null)]
        set_via:
          cli:
          - name: user
            option: --user
          env:
          - name: ANSIBLE_REMOTE_USER
          ini:
          - key: remote_user
            section: defaults
          vars:
          - name: ansible_user
          - name: ansible_ssh_user
```