# Домашнее задание к занятию "09.04 Jenkins"

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

[Репозиторий](https://github.com/beletsky/netology-ansible-role-kibana)

Сценарий сборки:
```jenkins
cd ansible-role-kibana
pip3 install -r test-requirements.txt
molecule test
```

2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

[Репозиторий](https://github.com/beletsky/netology-ansible-role-kibana)

Сценарий сборки:
```jenkins
pipeline {
    agent any
    stages {
        stage('checkout') {
            steps {
                dir('ansible-role-kibana') {
                    git credentialsId: 'GitHub-beletsky', url: 'https://github.com/beletsky/netology-ansible-role-kibana'
                }
            }
        }
        stage('install requirements') {
            steps {
                dir('ansible-role-kibana') {
                    sh 'pip3 install -r test-requirements.txt'
                }
            }
        }
        stage('run molecule') {
            steps {
                dir('ansible-role-kibana') {
                    sh 'molecule test'
                }
            }
        }
    }
}
```

3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.

[Jenkinsfile](https://github.com/beletsky/netology-ansible-role-kibana/raw/master/Jenkinsfile)

4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.

Сработал, автоматически запускал сборку при изменении репозитория.

5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.

```jenkins
node{
    properties([
        parameters([
            booleanParam(
                name: 'prod_run',
                defaultValue: false,
                description: 'Run the ansible playbook in production mode. If false, --check and --diff will be used for running.'
            )
        ])
    ])
    stage("Git checkout"){
        git credentialsId: 'GitHub-beletsky', url: 'https://github.com/aragastmatb/example-playbook.git'
    }
    stage("Run playbook"){
        sshagent (credentials: ['GitHub-beletsky']) {
            sh 'ansible-galaxy install -r requirements.yml -p roles'
        }
        if (params.prod_run){
            sh 'ansible-playbook site.yml -i inventory/prod.yml'
        }
        else{
            sh 'ansible-playbook --check --diff site.yml -i inventory/prod.yml'
        }
    }
}
```

7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.

[ScriptedJenkinsfile](./ScriptedJenkinsfile)

Для работы данного скрипта потребовалось дополнительно к описанному в задании:
- установить в Jenkins плагин `SSH Agent`;
- разрешить пользователю `jenkins` на агенте выполнять команды `sudo` без ввода пароля, путём добавления в `sudoers` строки: `jenkins ALL=(ALL) NOPASSWD:ALL`.