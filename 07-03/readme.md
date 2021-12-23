# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

> Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
> терраформа и aws. 
> 
> 1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
> а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
> [здесь](https://www.terraform.io/docs/backends/types/s3.html).
> 1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 


## Задача 2. Инициализируем проект и создаем воркспейсы. 

> 1. Выполните `terraform init`:
>     * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
> dynamodb.
>     * иначе будет создан локальный файл со стейтами.  
> 1. Создайте два воркспейса `stage` и `prod`.
> 1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
> использовались разные `instance_type`.
> 1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
> 1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
> 1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
> жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
> 1. При желании поэкспериментируйте с другими параметрами и рессурсами.
> 
> В виде результата работы пришлите:
> * Вывод команды `terraform workspace list`.
> * Вывод команды `terraform plan` для воркспейса `prod`.  

Я выполнил домашнее задание для провайдера Яндекс.Cloud. В конфигурации указаны два вида ресурсов: 
- `vm-count`, в котором количество экземпляров ресурса задаётся при помощи директивы `count` и зависит от текущего workspace;
- `vm-foreach`, экземпляры которого создаются итерацией по переданному списку.

В результате работы скрипта в workspace `prod` ожидаемо будут созданы два ресурса `vm-count` с именем `07-03-count-prod`, и два ресурса `vm-foreach` с именами `07-03-for-each-prod` и `07-03-for-each-stage`. 

```bash
$ terraform workspace list
  default
* prod
  stage
  
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm_count[0] will be created
  + resource "yandex_compute_instance" "vm_count" {
      + created_at                = (known after apply)
      + description               = "Homework 07-03"
      + folder_id                 = "b1gjc6s8ee54eedsvb9o"
      + fqdn                      = (known after apply)
      + hostname                  = "netology-07-03"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                user:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMms+VofMVXYt1it7nXIgRg5m1zfO0W7nG+uVyjks9e9 abeletsky@gmail.com
            EOT
        }
      + name                      = "07-03-count-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + description = (known after apply)
              + image_id    = "fd8f30hur3255mjfi3hq"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "e9bnq0s714tmjo39791g"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm_count[1] will be created
  + resource "yandex_compute_instance" "vm_count" {
      + created_at                = (known after apply)
      + description               = "Homework 07-03"
      + folder_id                 = "b1gjc6s8ee54eedsvb9o"
      + fqdn                      = (known after apply)
      + hostname                  = "netology-07-03"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                user:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMms+VofMVXYt1it7nXIgRg5m1zfO0W7nG+uVyjks9e9 abeletsky@gmail.com
            EOT
        }
      + name                      = "07-03-count-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + description = (known after apply)
              + image_id    = "fd8f30hur3255mjfi3hq"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "e9bnq0s714tmjo39791g"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm_foreach["prod"] will be created
  + resource "yandex_compute_instance" "vm_foreach" {
      + created_at                = (known after apply)
      + description               = "Homework 07-03"
      + folder_id                 = "b1gjc6s8ee54eedsvb9o"
      + fqdn                      = (known after apply)
      + hostname                  = "netology-07-03"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                user:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMms+VofMVXYt1it7nXIgRg5m1zfO0W7nG+uVyjks9e9 abeletsky@gmail.com
            EOT
        }
      + name                      = "07-03-for-each-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + description = (known after apply)
              + image_id    = "fd8f30hur3255mjfi3hq"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "e9bnq0s714tmjo39791g"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm_foreach["stage"] will be created
  + resource "yandex_compute_instance" "vm_foreach" {
      + created_at                = (known after apply)
      + description               = "Homework 07-03"
      + folder_id                 = "b1gjc6s8ee54eedsvb9o"
      + fqdn                      = (known after apply)
      + hostname                  = "netology-07-03"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                user:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMms+VofMVXYt1it7nXIgRg5m1zfO0W7nG+uVyjks9e9 abeletsky@gmail.com
            EOT
        }
      + name                      = "07-03-for-each-stage"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + description = (known after apply)
              + image_id    = "fd8f30hur3255mjfi3hq"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "e9bnq0s714tmjo39791g"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform
apply" now.
```

