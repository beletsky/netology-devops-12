# Домашнее задание к занятию "6.6. Troubleshooting"

## Задача 1

> Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).
> 
> Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD операция в MongoDB и её 
> нужно прервать. 
> 
> Вы как инженер поддержки решили произвести данную операцию:
> - напишите список операций, которые вы будете производить для остановки запроса пользователя
> - предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB

Для поиска долго выполняющегося запроса используем вызов (3 минуты = 180 секунд):
```mongo
db.currentOp({"secs_running":{$gte: 180}})
```
Прервать выполнение длительной операции можно при помощи вызова:
```mongo
db.killOp(13)
```
где вместо 13 нужно подставить Id процесса, который нужно прервать.

Для уменьшения времени выполнения запросов в MongoDB можно использовать как типовые для всех СУБД методы (переформулирование запроса; выборка/обработка меньшего количества данных за один запрос; создание индексов; подсказки СУБД, какие индексы использовать), так и специфические для данной СУБД методы, обусловленные спецификой решаемых ею задач и используемых для работы методов хранения и обработки данных (денормализация данных, сокращение названий полей и сжатие данных для уменьшения размера хранимых данных).

В целом, как правило, проблемы с медленными запросами эффективнее всего решаются именно на клиентском уровне: изменением логики работы приложения, способов хранения данных, и даже сменой СУБД на более подходящую для решения имеющихся задач. Неправильно выбранный инструмент, даже при самой лучшей его настройке, не сможет показать сравнимый результат по сравнению со специализированным, или даже просто более подходящем для конкретной задачи.

## Задача 2

> Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).
> 
> Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL. 
> Причем отношение количества записанных key-value значений к количеству истёкших значений есть величина постоянная и
> увеличивается пропорционально количеству реплик сервиса. 
> 
> При масштабировании сервиса до N реплик вы увидели, что:
> - сначала рост отношения записанных значений к истекшим
> - Redis блокирует операции записи
> 
> Как вы думаете, в чем может быть проблема?
 
Судя по описанию симптомов проблемы, клиентское приложение помещает в Redis большое количество новых записей практически единовременно. Из-за этого идёт рост отношения записанных значений к истёкшим. При этом TTL у эти записей выставлен очень близко друг к другу. Поэтому когда TTL истекает, Redis в очередной цикл активного удаления небольшого количества устаревших записей обнаруживает, что их количество  превышает заданную в нём величину 25% от общего количества записей, и переходит в блокирующий цикл удаления.

Решением проблемы может быть, например, искусственное разнесение TTL записей во времени.

## Задача 3

> Перед выполнением задания познакомьтесь с документацией по [Common Mysql errors](https://dev.mysql.com/doc/refman/8.0/en/common-errors.html).
> 
> Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей, в таблицах базы,
> пользователи начали жаловаться на ошибки вида:
> ```python
> InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
> ```
> 
> Как вы думаете, почему это начало происходить и как локализовать проблему?
> 
> Какие пути решения данной проблемы вы можете предложить?

Поскольку по условию задачи указано, что данная ошибка стала чаще появляться только с ростом количества записей в таблицах БД, наиболее вероятная её причина состоит в том, что в запросе `SELECT` запрашивается очень большое количество данных, и СУБД не успевает передать их все клиенту за время, указанное в настройке [net_read_timeout](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_net_read_timeout) (по умолчанию 30 секунд). Для подтверждения данной диагностики можно подсчитать количество записей, возвращаемых проблемным запросом (выполнить `SELECT COUNT(*) ...` на его основе), либо как-то ограничить выборку в запросе и убедиться, что он успешно выполняется в пределах `net_read_timeout`.

Для исправления проблемы:
1. Наиболее правильно будет переработать логику клиентского приложения, чтобы оно не требовало получения такого большого объёма данных.
2. Если это невозможно (как правило, такое бывает только в случае, когда нужно как можно скорее решить проблему, и времени на переработку приложения нет) - увеличить значение настройки `net_read_timeout`.

Менее вероятной причиной данной ошибки может быть хранение в поле данных типа `BLOB` значения с размером, превышающим указанный в настройке [max_allowed_packet](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_max_allowed_packet). Диагностика данного случая сводится к сравнению результатов выполнения запросов включающих и исключающих значение поля, попадающего "под подозрение". Исправление тривиально: уменьшение размера хранимого значения, либо увеличение настройки `max_allowed_packet`.

Наконец, данная ошибка может проявляться при проблемах сетевой связности клиентов и СУБД. Однако в таком случае ошибки начали бы появляться сразу же, а не "при росте количества записей", как указано в условии. Поэтому данная причина маловероятна.  

## Задача 4

> Перед выполнением задания ознакомтесь со статьей [Common PostgreSQL errors](https://www.percona.com/blog/2020/06/05/10-common-postgresql-errors/) из блога Percona.
> 
> Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с 
> большим объемом данных лучше, чем MySQL.
> 
> После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:
> 
> `postmaster invoked oom-killer`
> 
> Как вы думаете, что происходит?
> 
> Как бы вы решили данную проблему?

OOM-killer останавливает процессы в случае острой нехватки оперативной памяти даже для нормальной работы ОС. Основных причин данной проблемы две:
- неправильная настройка параметров СУБД, отвечающих за лимиты использования оперативной памяти;
- запуск на хосте каких-то требовательных к оперативной памяти сервисов, не связанных с СУБД.

Для диагностики проблемы необходимо отслеживать в системе мониторинга количество занятой оперативной памяти, занятой исполняемыми на сервере процессами. Это позволит выявить процесс, который приводит к запуску OOM-killer.

В первом случае, когда всю память расходует сама СУБД, нужно проверять настройки Postgres, задающие использование оперативной памяти, прежде всего `shared_buffers`, `work_mem`, `maintenance_work_mem` и `effective_cache_size`.

Во втором случае, очевидно, необходимо умерить аппетиты стороннего процесса.