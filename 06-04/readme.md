# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

> Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
> 
> Подключитесь к БД PostgreSQL используя `psql`.
> 
> Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.
> 
> **Найдите и приведите** управляющие команды для:
> - вывода списка БД
> - подключения к БД
> - вывода списка таблиц
> - вывода описания содержимого таблиц
> - выхода из psql

```bash
$ docker run --name netology-06-04 -e POSTGRES_PASSWORD=postgres -v /home/andrey/work/netology/devops-12/06-04/data:/var/lib/postgresql/data -v /home/andrey/work/netology/devops-12/06-04/test_data:/backup -p 5432:5432 -d postgres:13
```
```bash
$ docker exec -it --user postgres netology-06-04 bash
postgres@86e86c79fefe:/$ psql
psql (13.5 (Debian 13.5-1.pgdg110+1))
Type "help" for help.

postgres=# \l+
                                                                   List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   |  Size   | Tablespace |                Description

-----------+----------+----------+------------+------------+-----------------------+---------+------------+---------------------------------
-----------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |                       | 7901 kB | pg_default | default administrative connectio
n database
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +| 7753 kB | pg_default | unmodifiable empty database
           |          |          |            |            | postgres=CTc/postgres |         |            |
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +| 7753 kB | pg_default | default template for new databas
es
           |          |          |            |            | postgres=CTc/postgres |         |            |
(3 rows)

postgres=# \c postgres
You are now connected to database "postgres" as user "postgres".

postgres=# \dt+
Did not find any relations.

postgres=# \d+
Did not find any relations.

postgres=# \q
postgres@86e86c79fefe:/$
```

## Задача 2

> Используя `psql` создайте БД `test_database`.
> 
> Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).
> 
> Восстановите бэкап БД в `test_database`.
> 
> Перейдите в управляющую консоль `psql` внутри контейнера.
> 
> Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
> 
> Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
> с наибольшим средним значением размера элементов в байтах.
> 
> **Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```bash
postgres@86e86c79fefe:/$ psql
psql (13.5 (Debian 13.5-1.pgdg110+1))
Type "help" for help.

postgres=# create database test_database;
CREATE DATABASE
postgres=# \q
postgres@86e86c79fefe:/$ psql test_database < /backup/test_dump.sql
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
postgres@86e86c79fefe:/$ psql
psql (13.5 (Debian 13.5-1.pgdg110+1))
Type "help" for help.

postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".
test_database=# \dt+
                              List of relations
 Schema |  Name  | Type  |  Owner   | Persistence |    Size    | Description
--------+--------+-------+----------+-------------+------------+-------------
 public | orders | table | postgres | permanent   | 8192 bytes |
(1 row)

test_database=# analyze orders;
ANALYZE

test_database=# select attname, avg_width, rank() over (order by avg_width desc) as rank from pg_stats where schemaname='public' and tablename='orders' order by rank limit 1;
 attname | avg_width | rank
---------+-----------+------
 title   |        16 |    1
(1 row)
```

## Задача 3

> Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
> поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
> провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
> 
> Предложите SQL-транзакцию для проведения данной операции.
> 
> Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

По возможности вначале хорошо бы выяснить количество записей, которое ожидается в каждой из двух новых таблиц. Это поможет минимизировать копирование данных при создании новой таблицы.

```postgresql
test_database=# select count(*) from orders where price > 499;
 count
-------
     3
(1 row)

test_database=# select count(*) from orders where not price > 499;
 count
-------
     5
(1 row)
```

Видим, что выгоднее создавать новую таблицу для данных `price > 499`. Начинаем транзакцию и создаём новую таблицу.
```postgresql
test_database=# begin;
BEGIN
test_database=*# create table orders_1 (like orders including all);
CREATE TABLE
```
Переносим в новую таблицу данные из существующей.
```postgresql
test_database=*# insert into orders_1 select * from orders where price > 499;
INSERT 0 3
test_database=*# delete from orders where price > 499;
DELETE 3
```
Переименовываем старую таблицу (уже содержащую нужные данные) в новое имя, и завершаем транзакцию.
```postgresql
test_database=*# alter table orders rename to orders_2;
ALTER TABLE
test_database=*# commit;
COMMIT
```

Отмечу, что практически данный метод разделения таблицы на две слабо или вообще неприменим по многим причинам.

- такой метод требует остановки работы с таблицей orders на время разделения, плюс одновременной замены всей кодовой базы, которая работает с данной таблицей;
- копирование больших объёмов данных займёт много времени и создаст сильную нагрузку на СХД;
- удаление больших объёмов данных из прежней таблицы также весьма ресурсоёмкая операция, прежде всего из-за накладываемых на удаляемые строки блокировок;
- наконец, объём транзакции легко может превысить допустимый, что приведёт к её откату (с двойными потерями времени).

Решения этих проблем существуют, но они слегка :-) выходят за рамки данного задания.

Партиционирование таблицы, про которое фактически просят рассказать в последнем вопросе задачи, является одним из возможных решений. Для этого нам следовало изначально создать таблицу с двумя разделам по условию `price > 499`:
```postgresql
CREATE TABLE orders
(
    id INTEGER NOT NULL,
    title VARCHAR(80) NOT NULL,
    price INTEGER DEFAULT 0,
    PRIMARY KEY (id, price)
) PARTITION BY RANGE (price);

CREATE TABLE orders_greater PARTITION OF orders FOR VALUES FROM (500) TO (MAXVALUE);
CREATE TABLE orders_less PARTITION OF orders FOR VALUES FROM (MINVALUE) TO (500);

INSERT INTO orders VALUES (1, '1', 400);
INSERT INTO orders VALUES (2, '1', 499);
INSERT INTO orders VALUES (3, '1', 500);
INSERT INTO orders VALUES (4, '1', 600);

SELECT * FROM orders_less;
SELECT * FROM orders_greater;
```

Пример совершенно синтетический, потому что в реальности партиционирование обычно используется для разнесения данных по временнОму критерию (например, "горячие" данные на быстром диске, "холодные" на медленном, старые вообще уходят в резервные копии навсегда). А такой сценарий использования подразумевает несколько большие проблемы с организацией хранилища, включая регулярные добавления, переносы, и удаления разделов таблицы.

## Задача 4

> Используя утилиту `pg_dump` создайте бекап БД `test_database`.
> 
> Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```bash
root@86e86c79fefe:/# (su postgres -c "pg_dump test_database") > /backup/test_database_20211201_2014
```

Для обеспечения уникальности столбца `title` добавляем в файл резервной копии строки:
```postgresql
ALTER TABLE ONLY public.orders_1 ADD CONSTRAINT orders_1_utitle UNIQUE (title);
ALTER TABLE ONLY public.orders_2 ADD CONSTRAINT orders_2_utitle UNIQUE (title);
```
