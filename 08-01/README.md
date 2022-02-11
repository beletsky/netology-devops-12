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