# Домашнее задание к занятию "7.1. Инфраструктура как код"

## Задача 1. Выбор инструментов. 
 
> ### Легенда
>  
> Через час совещание на котором менеджер расскажет о новом проекте. Начать работу над которым надо будет уже сегодня. 
> На данный момент известно, что это будет сервис, который ваша компания будет предоставлять внешним заказчикам.
> Первое время, скорее всего, будет один внешний клиент, со временем внешних клиентов станет больше.
> 
> Так же по разговорам в компании есть вероятность, что техническое задание еще не четкое, что приведет к большому количеству небольших релизов, тестирований интеграций, откатов, доработок, то есть скучно не будет.  
>    
> Вам, как девопс инженеру, будет необходимо принять решение об инструментах для организации инфраструктуры.
> На данный момент в вашей компании уже используются следующие инструменты: 
> - остатки Сloud Formation, 
> - некоторые образы сделаны при помощи Packer,
> - год назад начали активно использовать Terraform, 
> - разработчики привыкли использовать Docker, 
> - уже есть большая база Kubernetes конфигураций, 
> - для автоматизации процессов используется Teamcity, 
> - также есть совсем немного Ansible скриптов, 
> - и ряд bash скриптов для упрощения рутинных задач.  
> 
> Для этого в рамках совещания надо будет выяснить подробности о проекте, что бы в итоге определиться с инструментами:
> 
> 1. Какой тип инфраструктуры будем использовать для этого проекта: изменяемый или не изменяемый?
> 1. Будет ли центральный сервер для управления инфраструктурой?
> 1. Будут ли агенты на серверах?
> 1. Будут ли использованы средства для управления конфигурацией или инициализации ресурсов? 
>  
> В связи с тем, что проект стартует уже сегодня, в рамках совещания надо будет определиться со всеми этими вопросами.
> 
> ### В результате задачи необходимо
> 
> 1. Ответить на четыре вопроса представленных в разделе "Легенда". 
> 1. Какие инструменты из уже используемых вы хотели бы использовать для нового проекта? 
> 1. Хотите ли рассмотреть возможность внедрения новых инструментов для этого проекта? 
> 
> Если для ответа на эти вопросы недостаточно информации, то напишите какие моменты уточните на совещании.

1. Поскольку согласно заданию "техническое задание еще не четкое, что приведет к большому количеству небольших релизов, тестирований интеграций, откатов, доработок", очевидно, что использовать для данного проекта подход с неизменяемой инфраструктурой будет очень неудобно. Любое, даже минорное, изменение в технических составляющих проекта приводило бы к полной пересборке всей инфраструктуры, что долго и очень неудобно для разработчиков.  
   Поэтому имеет смысл на начальном этапе использовать изменяемую инфраструктуру, например, при помощи Docker (для разработчиков) и Ansible (для администраторов), при этом по возможности постепенно перенося уже устоявшиеся технические решения из них на уровень сборки и развёртывания образов при помощи Packer и Terraform.


2. Поскольку "Первое время, скорее всего, будет один внешний клиент", я не вижу большого смысла сразу внедрять решения с центральным сервером управления инфраструктурой. Скорее всего, для одного клиента будет вполне достаточно возможностей, предоставляемых простым Docker swarm, в крайнем случае - Kubernetes, физически размещённых на заранее выделенном неизменном количестве серверов (без масштабирования).  
   В дальнейшем, при появлении множества клиентов и (важно!) правильно выбранной и реализованной архитектуре приложения будет иметь широко применять автомасштабирование системы при помощи Kubernetes.  
  С самого начала важно понимать, может ли разрабатываемая система быть размещена на публичных сервисах, или она требует создания собственной приватной инфраструктуры (секретные данные, например). В первом случае дальнейшее развитие системы может быть осущественно по прежнему без центрального сервера (необходимый мониторинг аппаратной составляющей будет обеспечивать внешний сервис), на основе Packer и Terraform. Во втором случае, при необходимости подымать и обслуживать собственный парк серверов, наличие центрального сервера является практически необходимым, и нужно будет включать его внедрение в план развития.


3. Ответ на данный вопрос сильно зависит от методологии разработки, которая будет применяться на данном проекте. Существенными являются два вопроса: 1) важно ли разработчикам на начальном этапе иметь доступ к инфраструктуре для того, чтобы, например, проводить на ней эксперименты с разным ПО, с разными настройками, с разными архитектурами ПО; 2) готовы ли специалисты DevOps в реальном времени отслеживать изменения, требуемые разработчиками, в файлы конфигураций.  
   Использование агентов имеет смысл в случаях, когда ответ на первый вопрос "нет" или на второй "да". В оставшемся случае 1) "да", 2) "нет" - использование агентов только сильно усложнит жизнь разработчиков, не принеся никакой пользы ни одной из сторон.  
  На мой взгляд, в любом случае на начальном этапе, пока архитектура и инфраструктура проекта ещё не устоялись, использование агентов является нецелесообразным. Однако в какой-то момент развития, скорее всего при появлении первых задач на масштабирование инфраструктуры, имеет смысл зафиксировать текущие конфигурации и перейти к использованию агентов для их поддержания (с надеждой, что инфраструктура уже устоялась, и изменения будут не такими частыми). Это особенно важно, если разработчики будут иметь доступ к production-инфраструктуре, либо сам проект подразумевает возможности какой-то ручной работы с ней администраторов. Это позволит существенно увеличить стабильность системы, поскольку уменьшится вероятность внезапных и неизвестных изменений в конфигурации.  
  Отдельно следует упомянуть об использовании агентов в development-среде, где разработчики могут проводить различные эксперименты с настройками и архитектурными решениями. Здесь они важны больше в плане отслеживания изменений, а не поддержания неизменной конфигурации.


4. На первом этапе использование средств управления конфигурацией и инициализации ресурсов кажется неразумным, по тем же причинами, что указаны в ответе на первый вопрос (конфигурация будет очень часто меняться). В дальнейшем решение об их использовании следует принимать с учётом характера реального использования сервиса (нагрузка, количество обрабатываемых данных, и т.д.) 

Для нового проекта я бы хотел использовать Docker для разработчиков и для создания образов ПО для развёртывания на серверах при помощи Docker swarm или Kubernetes, Ansible для управления конфигурацией серверов, Packer и Terraform для создания и развёртывания серверов.

Использование облачных сервисов интересно, если характер проекта позволяет развернуть его в облаках. Для автоматизации процессов вместо TeamCity я бы использовал какое-либо другое open-source решение (хотя это вкусовщина, и если TeamCity уже активно используется и знаком всем причастным, нет никакого смысла от него отказываться).

Возможность использования новых инструментов следует увязывать с временными и бюджетными планами реализации нового проекта. Если он является приоритетным либо малобюджетным, лучше ограничиться использованием уже знакомых средств. Если сроки и бюджет позволяют, имеет смысл попробовать внедрить на проекте какое-нибудь новое решение.

## Задача 2. Установка терраформ. 

> Официальный сайт: https://www.terraform.io/
> 
> Установите терраформ при помощи менеджера пакетов используемого в вашей операционной системе.
> В виде результата этой задачи приложите вывод команды `terraform --version`.

```bash
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
...
Reading package lists... Done

$ sudo apt-get update && sudo apt-get install terraform
...
Get:1 https://apt.releases.hashicorp.com focal/main amd64 terraform amd64 1.1.1 [18.7 MB]
Fetched 18.7 MB in 2s (8527 kB/s)
Selecting previously unselected package terraform.
(Reading database ... 41000 files and directories currently installed.)
Preparing to unpack .../terraform_1.1.1_amd64.deb ...
Unpacking terraform (1.1.1) ...
Setting up terraform (1.1.1) ...

$ terraform --version
Terraform v1.1.1
on linux_amd64
```

## Задача 3. Поддержка легаси кода. 

> В какой-то момент вы обновили терраформ до новой версии, например с 0.12 до 0.13. 
> А код одного из проектов настолько устарел, что не может работать с версией 0.13. 
> В связи с этим необходимо сделать так, чтобы вы могли одновременно использовать последнюю версию терраформа установленную при помощи штатного менеджера пакетов и устаревшую версию 0.12. 
> 
> В виде результата этой задачи приложите вывод `--version` двух версий терраформа доступных на вашем компьютере или виртуальной машине.

```bash
$ wget https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip
--2021-12-17 12:39:09--  https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip
Resolving releases.hashicorp.com (releases.hashicorp.com)... 151.101.1.183, 151.101.65.183, 151.101.129.183, ...
Connecting to releases.hashicorp.com (releases.hashicorp.com)|151.101.1.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 28441056 (27M) [application/zip]
Saving to: ‘terraform_0.12.31_linux_amd64.zip’

terraform_0.12.31_linux_amd64.zip  100%[================================================================>]  27.12M  8.41MB/s    in 3.5s

2021-12-17 12:39:13 (7.79 MB/s) - ‘terraform_0.12.31_linux_amd64.zip’ saved [28441056/28441056]

$ unzip terraform_0.12.31_linux_amd64.zip -d ~/.local/bin/
Archive:  terraform_0.12.31_linux_amd64.zip
  inflating: /home/andrey/.local/bin/terraform

$ terraform --version
Terraform v1.1.1
on linux_amd64

$ ~/.local/bin/terraform --version
Terraform v0.12.31

Your version of Terraform is out of date! The latest version
is 1.1.1. You can update by downloading from https://www.terraform.io/downloads.html
```