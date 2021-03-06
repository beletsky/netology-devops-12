# Домашнее задание к занятию "7.4. Средства командной работы над инфраструктурой."

## Задача 1. Настроить terraform cloud (необязательно, но крайне желательно).

> В это задании предлагается познакомиться со средством командой работы над инфраструктурой предоставляемым
> разработчиками терраформа. 
> 
> 1. Зарегистрируйтесь на [https://app.terraform.io/](https://app.terraform.io/).
> (регистрация бесплатная и не требует использования платежных инструментов).
> 1. Создайте в своем github аккаунте (или другом хранилище репозиториев) отдельный репозиторий с
>  конфигурационными файлами прошлых занятий (или воспользуйтесь любым простым конфигом).
> 1. Зарегистрируйте этот репозиторий в [https://app.terraform.io/](https://app.terraform.io/).
> 1. Выполните plan и apply. 
> 
> В качестве результата задания приложите снимок экрана с успешным применением конфигурации.

Не выполнял данное задание. Постараюсь на новогодних праздниках сделать его.

## Задача 2. Написать серверный конфиг для атлантиса. 

> Смысл задания – познакомиться с документацией 
> о [серверной](https://www.runatlantis.io/docs/server-side-repo-config.html) конфигурации и конфигурации уровня 
>  [репозитория](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html).
> 
> Создай `server.yaml` который скажет атлантису:
> 1. Укажите, что атлантис должен работать только для репозиториев в вашем github (или любом другом) аккаунте.
> 1. На стороне клиентского конфига разрешите изменять `workflow`, то есть для каждого репозитория можно 
> будет указать свои дополнительные команды. 
> 1. В `workflow` используемом по-умолчанию сделайте так, что бы во время планирования не происходил `lock` состояния.
> 
> Создай `atlantis.yaml` который, если поместить в корень terraform проекта, скажет атлантису:
> 1. Надо запускать планирование и аплай для двух воркспейсов `stage` и `prod`.
> 1. Необходимо включить автопланирование при изменении любых файлов `*.tf`.
> 
> В качестве результата приложите ссылку на файлы `server.yaml` и `atlantis.yaml`.

[atlantis/server.yaml](atlantis/server.yaml) - в комментариях пометил настройки, которые выполняют условия задачи.

[atlantis/atlantis.yaml](atlantis/atlantis.yaml) - для поддержки двух воркспейсов необходимо сделать два отдельных входа в блоке `projects` с одинаковыми `dir` (`.` - текущий каталог, т.е. корневой каталог проекта) и различающимися значениями `workspace`. 

## Задача 3. Знакомство с каталогом модулей. 

> 1. В [каталоге модулей](https://registry.terraform.io/browse/modules) найдите официальный модуль от aws для создания
> `ec2` инстансов. 
> 2. Изучите как устроен модуль. Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно 
> ресурс `aws_instance` без помощи модуля?
> 3. В рамках предпоследнего задания был создан ec2 при помощи ресурса `aws_instance`. 
> Создайте аналогичный инстанс при помощи найденного модуля.   
> 
> В качестве результата задания приложите ссылку на созданный блок конфигураций. 

В задаче идёт речь о модуле [ec2-instance](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest). Данный модуль по сути "разворачивает" все значения параметров, которые можно использовать внутри ресурса `aws_instance` в один большой плоский список параметров с использованием различных структур данных.

Для простых конфигураций с небольшим количеством ресурсов его использование большого смысла не имеет. Плоский список параметров будет затруднять чтение и понимание конфигурации ресурса, а также слегка затруднит его модификацию (нужно будет не только найти нужную конфигурацию для ресурса `aws_instance`, но и дополнительно разобраться, как входные данные для такой конфигурации задаются в модуле).

Однако, его использование будет иметь смысл, если нужно создать большое количество однотипных ресурсов, либо для ресурса нужно создать большое количество однотипных вложенных объектов, например, дисков, подсетей, и т.д. В этом случае будет гораздо проще задать их характеристики в виде списков, словарей, кортежей в конфигурации модуля, чем писать множество сложных вложенных конфигурационных конструкций.

К сожалению, я выполнял домашние задания данного блока в облаке Яндекс, и не регистрировался в AWS. Было бы глупо приводить в качестве ответа скопированный пример из документации модуля. Надеюсь, что на предстоящих праздниках у меня будет возможность детально изучить с AWS и разобраться с примерами и задачами из данного модуля применительно к нему.