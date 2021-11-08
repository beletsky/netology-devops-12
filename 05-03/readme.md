# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Задача 1

> Сценарий выполнения задачи:
> 
> - создайте свой репозиторий на https://hub.docker.com;
> - выберете любой образ, который содержит веб-сервер Nginx;
> - создайте свой fork образа;
> - реализуйте функциональность:
> запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
> ```
> <html>
> <head>
> Hey, Netology
> </head>
> <body>
> <h1>I’m DevOps Engineer!</h1>
> </body>
> </html>
> ```
> Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

[Docker Hub Image](https://hub.docker.com/r/abeletskiyppr/netology_05_03)

Пример запуска:
```bash
docker run --rm -p 8888:80 -d abeletskiyppr/netology_05_03
```

[Результат работы](index.html.png)

## Задача 2

> Посмотрите на сценарий ниже и ответьте на вопрос:
> "Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"
> 
> Детально опишите и обоснуйте свой выбор.
> 
> --
> 
> Сценарий:
> 
> - Высоконагруженное монолитное java веб-приложение;
> - Nodejs веб-приложение;
> - Мобильное приложение c версиями для Android и iOS;
> - Шина данных на базе Apache Kafka;
> - Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
> - Мониторинг-стек на базе Prometheus и Grafana;
> - MongoDB, как основное хранилище данных для java-приложения;
> - Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Обычно работают такие общие соображения по выбору среды запуска сервисов: 

- сервисы, связанные с хранением данных (базы данных, очереди, и т.д.) должны быть размещены на физических серверах;
- сервисы, обрабатывающие и преобразующие данные, могут быть вынесены на виртуальные машины и в контейнеры;
- выгодно запускать в контейнерах хорошо горизонтально масштабируемые сервисы (при условии, что такая масштабируемость реально нужна, например, в случае плавающей по времени нагрузке);
- не имеет особого смысла (кроме удобства администрирования, что зачастую действительно сильно экономит время и силы) использовать контейнеры для сервисов, количество экземпляров которых фиксировано либо не может быть изменено динамически.
  
Отмечу также, что в development-среде использовать контейнеры можно (и зачастую довольно удобно так и делать) практически для любых типов приложений. Поэтому ответы дальше формулирую для production-сред. 

- Высоконагруженное монолитное java веб-приложение;

  Для данного сценария лучше подойдёт физическая машина либо виртуальная машина, в зависимости от того, используется ли интенсивная работа с диском, или же для работы приложения нужна в основном оперативная память. Использование контейнеризации необоснованно, потому что такие приложения не масштабируются горизонтально, как правило, хранят состояние, и не могут быть разделены на несколько асинхронно работающих частей.
  

- Nodejs веб-приложение;

  Данные приложения являются идеальными кандидатами для размещения в контейнерах, потому что они, как правило, являются stateless-приложениями, и легко горизонтально масштабируются, и являются быстродействующими (создание ответа за запрос не занимает много времени и ресурсов).
  

- Мобильное приложение c версиями для Android и iOS;

  Мобильные приложения работают в единственном экземпляре на специализированной аппаратуре, поэтому об их контейнеризация бессмысленна.
  

- Шина данных на базе Apache Kafka;

  Kafka (предполагаем, что она высоконагруженная, иначе смысла в ней особого нет) обладает высокими требованиями к быстродействию системы хранения данных, а это значит, что её нужно запускать как можно ближе к железу, идеально - на физическом сервере.
  

- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;

  Как и в случае с Kafka, ноды elasticsearch требовательны к быстродействию СХД, поэтому для них оптимальным выбором является физический сервер. Ноды logstash и kibana можно размещать на виртуальных машинах, потому что они, как правило, не являются высоконагруженными. Размещать эти сервисы в контейнерах особого смысла нет, потому что полностью отсутствует необходимость их горизонтального масштабирования, но это можно сделать из соображений удобства администрирования. 
  

- Мониторинг-стек на базе Prometheus и Grafana;

  Как и в предыдущем случае, Prometheus имеет смысл разместить на физическом сервере (важно быстродействие СХД), Grafana может быть размещена на виртуальном сервере или же в контейнере для удобства развёртывания и обновления. 
  

- MongoDB, как основное хранилище данных для java-приложения;

  MongoDB, как и любые системы хранения данных, требовательные к скорости доступа к СХД, нужно размещать как можно ближе к железу, то есть на физическом сервере. 
  

- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

  Использовать Gitlab сервер в контейнере имеет смысл из-за удобства его развёртывания и последующего обновления.  

## Задача 3

> - Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
> - Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
> - Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
> - Добавьте еще один файл в папку ```/data``` на хостовой машине;
> - Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

```bash
$ docker run --rm -t -v /home/andrey/work/netology/devops-12/05-03/data:/data -d centos:centos7
7bd857a082c42f22408556ae6af8096e049e2bb64c24708284958f87da42e6b3
$ docker run --rm -t -v /home/andrey/work/netology/devops-12/05-03/data:/data -d debian:latest
02ed76b20a6e61152be4f88199c01e836dc3989a7d82b85949ff5f82b8d95b89
$ docker exec -it 7bd857a082c42f22408556ae6af8096e049e2bb64c24708284958f87da42e6b3 bash
[root@7bd857a082c4 /]# touch /data/file_centos.txt
[root@7bd857a082c4 /]# ls -la /data
total 8
drwxr-xr-x 2 root root 4096 Nov  8 16:26 .
drwxr-xr-x 1 root root 4096 Nov  8 16:25 ..
-rw-r--r-- 1 root root    0 Nov  8 16:26 file_centos.txt
[root@7bd857a082c4 /]# exit
exit
$ sudo touch data/file_host.txt
[sudo] password for andrey:
$ ls -la data
total 8
drwxr-xr-x 2 root   root   4096 Nov  8 19:26 .
drwxr-xr-x 3 andrey andrey 4096 Nov  8 19:25 ..
-rw-r--r-- 1 root   root      0 Nov  8 19:26 file_centos.txt
-rw-r--r-- 1 root   root      0 Nov  8 19:26 file_host.txt
$ docker exec -it 02ed76b20a6e61152be4f88199c01e836dc3989a7d82b85949ff5f82b8d95b89 bash
root@02ed76b20a6e:/# ls -la /data
total 8
drwxr-xr-x 2 root root 4096 Nov  8 16:26 .
drwxr-xr-x 1 root root 4096 Nov  8 16:25 ..
-rw-r--r-- 1 root root    0 Nov  8 16:26 file_centos.txt
-rw-r--r-- 1 root root    0 Nov  8 16:26 file_host.txt
root@02ed76b20a6e:/# exit
exit
```

## Задача 4 (*)

> Воспроизвести практическую часть лекции самостоятельно.
> 
> Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

[Docker Hub Image](https://hub.docker.com/r/abeletskiyppr/netology_05_03_ansible)

Пример запуска:
```bash
$ docker run --rm abeletskiyppr/netology_05_03_ansible
ansible-playbook 2.9.24
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.9/site-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 3.9.5 (default, May 12 2021, 20:44:22) [GCC 10.3.1 20210424]
  ```