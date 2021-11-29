# Домашнее задание к занятию "6.2. SQL"

## Задача 1

> Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
> в который будут складываться данные БД и бэкапы.
> 
> Приведите получившуюся команду или docker-compose манифест.

```bash
docker run --name netology-06-02-pg -e POSTGRES_PASSWORD=postgres -v /home/andrey/work/netology/devops-12/06-02/data:/var/lib/postgresql/data -v /home/andrey/work/netology/devops-12/06-02/backup:/backup -p 5432:5432 -d postgres:12.9
```

## Задача 2

> В БД из задачи 1: 
> - создайте пользователя test-admin-user и БД test_db
> - в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
> - предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
> - создайте пользователя test-simple-user  
> - предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
> 
> Таблица orders:
> - id (serial primary key)
> - наименование (string)
> - цена (integer)
> 
> Таблица clients:
> - id (serial primary key)
> - фамилия (string)
> - страна проживания (string, index)
> - заказ (foreign key orders)
> 
> Приведите:
> - итоговый список БД после выполнения пунктов выше,
> - описание таблиц (describe)
> - SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
> - список пользователей с правами над таблицами test_db

```postgresql
postgres=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)

test_db=# \d+ orders
                                                        Table "public.orders"
 Column |          Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description
--------+------------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer                |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
 name   | character varying(255) |           |          |                                    | extended |              |
 cost   | integer                |           |          |                                    | plain    |              |
Indexes:
    "orders_pk" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_orders_id_fk" FOREIGN KEY ("order") REFERENCES orders(id)
Access method: heap

test_db=# \d+ clients
                                                        Table "public.clients"
 Column  |          Type          | Collation | Nullable |               Default               | Storage  | Stats target | Description
---------+------------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id      | integer                |           | not null | nextval('clients_id_seq'::regclass) | plain    |              |
 surname | character varying(255) |           |          |                                     | extended |              |
 country | character varying(255) |           |          |                                     | extended |              |
 order   | integer                |           |          |                                     | plain    |              |
Indexes:
    "clients_pk" PRIMARY KEY, btree (id)
    "clients_country_index" btree (country)
Foreign-key constraints:
    "clients_orders_id_fk" FOREIGN KEY ("order") REFERENCES orders(id)
Access method: heap

test_db=# SELECT grantee AS user,
       CONCAT(table_schema, '.', table_name) AS table,
       ARRAY_TO_STRING(ARRAY_AGG(privilege_type), ', ') AS grants
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
GROUP BY table_name, table_schema, grantee
ORDER BY grantee;
       user       |     table      |                            grants
------------------+----------------+---------------------------------------------------------------
 postgres         | public.clients | TRIGGER, REFERENCES, TRUNCATE, DELETE, UPDATE, SELECT, INSERT
 postgres         | public.orders  | INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
 test-admin-user  | public.clients | TRIGGER, REFERENCES, TRUNCATE, DELETE, UPDATE, SELECT, INSERT
 test-admin-user  | public.orders  | DELETE, TRUNCATE, REFERENCES, TRIGGER, UPDATE, SELECT, INSERT
 test-simple-user | public.clients | DELETE, UPDATE, SELECT, INSERT
 test-simple-user | public.orders  | INSERT, SELECT, UPDATE, DELETE
(6 rows)
```

## Задача 3

> Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:
> 
> Таблица orders
> 
> |Наименование|цена|
> |------------|----|
> |Шоколад| 10 |
> |Принтер| 3000 |
> |Книга| 500 |
> |Монитор| 7000|
> |Гитара| 4000|
> 
> Таблица clients
> 
> |ФИО|Страна проживания|
> |------------|----|
> |Иванов Иван Иванович| USA |
> |Петров Петр Петрович| Canada |
> |Иоганн Себастьян Бах| Japan |
> |Ронни Джеймс Дио| Russia|
> |Ritchie Blackmore| Russia|
> 
> Используя SQL синтаксис:
> - вычислите количество записей для каждой таблицы 
> - приведите в ответе:
>     - запросы 
>     - результаты их выполнения.

```postgresql
test_db=# INSERT INTO orders (name, cost)
VALUES ('Шоколад', 10),
       ('Принтер', 3000),
       ('Книга', 500),
       ('Монитор', 7000),
       ('Гитара', 4000);
INSERT 0 5
test_db=# INSERT INTO clients (surname, country)
VALUES ('Иванов Иван Иванович', 'USA'),
       ('Петров Петр Петрович', 'Canada'),
       ('Иоганн Себастьян Бах', 'Japan'),
       ('Ронни Джеймс Дио', 'Russia'),
       ('Ritchie Blackmore', 'Russia');
INSERT 0 5
test_db=# SELECT COUNT(*) FROM orders;
 count
-------
     5
(1 row)

test_db=# SELECT COUNT(*) FROM clients;
 count
-------
     5
(1 row)
```

## Задача 4

> Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.
> 
> Используя foreign keys свяжите записи из таблиц, согласно таблице:
> 
> |ФИО|Заказ|
> |------------|----|
> |Иванов Иван Иванович| Книга |
> |Петров Петр Петрович| Монитор |
> |Иоганн Себастьян Бах| Гитара |
> 
> Приведите SQL-запросы для выполнения данных операций.
> 
> Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
>  
> Подсказка - используйте директиву `UPDATE`.

```postgresql
test_db=# UPDATE clients
SET "order" = (SELECT id FROM orders WHERE name = 'Книга')
WHERE surname = 'Иванов Иван Иванович';
UPDATE 1
test_db=# UPDATE clients
SET "order" = (SELECT id FROM orders WHERE name = 'Монитор')
WHERE surname = 'Петров Петр Петрович';
UPDATE 1
test_db=# UPDATE clients
SET "order" = (SELECT id FROM orders WHERE name = 'Гитара')
WHERE surname = 'Иоганн Себастьян Бах';
UPDATE 1
test_db=# SELECT *
FROM clients
WHERE "order" IS NOT NULL;
 id |       surname        | country | order
----+----------------------+---------+-------
  6 | Иванов Иван Иванович | USA     |     8
  7 | Петров Петр Петрович | Canada  |     9
  8 | Иоганн Себастьян Бах | Japan   |    10
(3 rows)
```

## Задача 5

> Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
> (используя директиву EXPLAIN).
> 
> Приведите получившийся результат и объясните что значат полученные значения.

```postgresql
test_db=# EXPLAIN ANALYSE
SELECT *
FROM clients
WHERE "order" IS NOT NULL;
                                              QUERY PLAN
------------------------------------------------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..10.70 rows=70 width=1040) (actual time=0.008..0.009 rows=3 loops=1)
   Filter: ("order" IS NOT NULL)
   Rows Removed by Filter: 2
 Planning Time: 0.031 ms
 Execution Time: 0.018 ms
(5 rows)
```

Будет выполнено последовательное сканирование (`Seq Scan`) всех строк таблицы `clients` и выбор строк, удовлетворяющих фильтру `"order" IS NOT NULL`. 

По факту выполнения запроса было получено три строки (`rows=3`), фильтром были отброшены 2 строки (`Rows Removed by Filter: 2`) из пяти (`5 rows`), и выполнение заняло `0.018 ms`.

## Задача 6

> Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
> 
> Остановите контейнер с PostgreSQL (но не удаляйте volumes).
> 
> Поднимите новый пустой контейнер с PostgreSQL.
> 
> Восстановите БД test_db в новом контейнере.
> 
> Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

Создаём резервную копию данных:

```bash
root@aa60d2efde3f:/# chown postgres:postgres /backup
root@aa60d2efde3f:/# su postgres
postgres@aa60d2efde3f:/$ pg_dump test_db > /backup/test_db_20211129_1734
postgres@aa60d2efde3f:/$ ll
bash: ll: command not found
postgres@aa60d2efde3f:/$ ls -la /backup/
total 16
drwxr-xr-x 2 postgres postgres 4096 Nov 29 14:35 .
drwxr-xr-x 1 root     root     4096 Nov 29 14:33 ..
-rw-r--r-- 1 postgres postgres 4356 Nov 29 14:35 test_db_20211129_1734
```

Подымаем новый контейнер с пустой БД:

```bash
docker run --name netology-06-02-pg2 -e POSTGRES_PASSWORD=postgres -v /home/andrey/work/netology/devops-12/06-02/data2:/var/lib/postgresql/data -v /home/andrey/work/netology/devops-12/06-02/backup:/backup -p 5432:5432 -d postgres:12.9
```

Восстанавливаем содержимое БД в новом контейнере:
```bash
root@b10ea432dfa1:/# su postgres
postgres@b10ea432dfa1:/$ createdb test_db
postgres@b10ea432dfa1:/$ psql test_db < /backup/test_db_20211129_1734
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
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval
--------
     10
(1 row)

 setval
--------
     10
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
ERROR:  role "test-simple-user" does not exist
ERROR:  role "test-admin-user" does not exist
ERROR:  role "test-simple-user" does not exist
ERROR:  role "test-admin-user" does not exist
postgres@b10ea432dfa1:/$ psql
psql (12.9 (Debian 12.9-1.pgdg110+1))
Type "help" for help.

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# select * from clients;
 id |       surname        | country | order
----+----------------------+---------+-------
  9 | Ронни Джеймс Дио     | Russia  |
 10 | Ritchie Blackmore    | Russia  |
  6 | Иванов Иван Иванович | USA     |     8
  7 | Петров Петр Петрович | Canada  |     9
  8 | Иоганн Себастьян Бах | Japan   |    10
(5 rows)
```

Как и ожидалось, было восстановлено только содержимое БД, но не пользователи и их права. Если нужно было бы перенести и их, то следовало бы использовать команду `pg_dumpall`.
