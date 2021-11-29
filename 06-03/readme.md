# Домашнее задание к занятию "6.3. MySQL"

## Задача 1

> Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
> 
> Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
> восстановитесь из него.
> 
> Перейдите в управляющую консоль `mysql` внутри контейнера.
> 
> Используя команду `\h` получите список управляющих команд.
> 
> Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
> 
> Подключитесь к восстановленной БД и получите список таблиц из этой БД.
> 
> **Приведите в ответе** количество записей с `price` > 300.
> 
> В следующих заданиях мы будем продолжать работу с данным контейнером.

```bash
$ docker run --name netology-06-03 -v /home/andrey/work/netology/devops-12/06-03/test_data/:/backup -e MYSQL_ROOT_PASSWORD=secret -d mysql:8

$ docker exec -it netology-06-03 bash

root@07de5dea2c7a:/# mysql -uroot -psecret -e "create database test_db;"
mysql: [Warning] Using a password on the command line interface can be insecure.
root@07de5dea2c7a:/# mysql -uroot -psecret -D test_db < /backup/test_dump.sql
mysql: [Warning] Using a password on the command line interface can be insecure.
root@07de5dea2c7a:/# mysql -uroot -psecret
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.27 MySQL Community Server - GPL

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show variables like 'version%';
+-------------------------+------------------------------+
| Variable_name           | Value                        |
+-------------------------+------------------------------+
| version                 | 8.0.27                       |
| version_comment         | MySQL Community Server - GPL |
| version_compile_machine | x86_64                       |
| version_compile_os      | Linux                        |
| version_compile_zlib    | 1.2.11                       |
+-------------------------+------------------------------+
5 rows in set (0.00 sec)

mysql> use test_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed

mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> select count(*) from orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

## Задача 2

> Создайте пользователя test в БД c паролем test-pass, используя:
> - плагин авторизации mysql_native_password
> - срок истечения пароля - 180 дней 
> - количество попыток авторизации - 3 
> - максимальное количество запросов в час - 100
> - аттрибуты пользователя:
>     - Фамилия "Pretty"
>     - Имя "James"
> 
> Предоставьте привилегии пользователю `test` на операции SELECT базы `test_db`.
>     
> Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и **приведите в ответе к задаче**.

```bash
mysql> CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass' WITH MAX_QUERIES_PER_HOUR 100 PASSWORD EXPIRE INTERVAL 180 DAY FAILED_LOGIN_ATTEMPTS 3 ATTRIBUTE '{"surname":"Pretty","name":"James"}';
Query OK, 0 rows affected (0.02 sec)

mysql> GRANT SELECT ON test_db.* TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> select * from information_schema.user_attributes where user = 'test';
+------+-----------+----------------------------------------+
| USER | HOST      | ATTRIBUTE                              |
+------+-----------+----------------------------------------+
| test | localhost | {"name": "James", "surname": "Pretty"} |
+------+-----------+----------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

> Установите профилирование `SET profiling = 1`.
> Изучите вывод профилирования команд `SHOW PROFILES;`.
> 
> Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
> 
> Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
> - на `MyISAM`
> - на `InnoDB`

```bash
mysql> show create table orders;
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table  | Create Table
                                                                                                         |
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| orders | CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(80) NOT NULL,
  `price` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci |
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)
```
ENGINE=InnoDB

```bash
mysql> set PROFILING=1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> alter table orders ENGINE=MyISAM;
Query OK, 5 rows affected (0.07 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> alter table orders ENGINE=InnoDB;
Query OK, 5 rows affected (0.19 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> show profiles;
+----------+------------+----------------------------------+
| Query_ID | Duration   | Query                            |
+----------+------------+----------------------------------+
|        1 | 0.07278725 | alter table orders ENGINE=MyISAM |
|        2 | 0.19046250 | alter table orders ENGINE=InnoDB |
+----------+------------+----------------------------------+
2 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

> Изучите файл `my.cnf` в директории /etc/mysql.
> 
> Измените его согласно ТЗ (движок InnoDB):
> - Скорость IO важнее сохранности данных
> - Нужна компрессия таблиц для экономии места на диске
> - Размер буффера с незакомиченными транзакциями 1 Мб
> - Буффер кеширования 30% от ОЗУ
> - Размер файла логов операций 100 Мб
> 
> Приведите в ответе измененный файл `my.cnf`.

Поскольку используемый в моей конфигурации файл `/etc/mysql/my.cnf` содержит строку 
```bash
!includedir /etc/mysql/conf.d/
```
лучше всего создать отдельный файл конфигурации сервера `/etc/mysql/conf.d/my.cnf`:

```bash
[mysqld]
innodb_flush_method = O_DSYNC
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 5M
innodb_log_file_size = 100M
```
Я использую версию 8 MySQL, в которой исключена опция `innodb_file_format=barracuda`, судя по всему, требуемая по условию "Нужна компрессия таблиц для экономии места на диске".
