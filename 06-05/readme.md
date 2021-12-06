# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

> В этом задании вы потренируетесь в:
> - установке elasticsearch
> - первоначальном конфигурировании elastcisearch
> - запуске elasticsearch в docker
> 
> Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
> [документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):
> 
> - составьте Dockerfile-манифест для elasticsearch
> - соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
> - запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины
> 
> Требования к `elasticsearch.yml`:
> - данные `path` должны сохраняться в `/var/lib`
> - имя ноды должно быть `netology_test`
> 
> В ответе приведите:
> - текст Dockerfile манифеста
> - ссылку на образ в репозитории dockerhub
> - ответ `elasticsearch` на запрос пути `/` в json виде
> 
> Подсказки:
> - возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
> - при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
> - при некоторых проблемах вам поможет docker директива ulimit
> - elasticsearch в логах обычно описывает проблему и пути ее решения
> 
> Далее мы будем работать с данным экземпляром elasticsearch.

```Dockerfile
FROM centos:7

COPY elasticsearch.repo /etc/yum.repos.d/

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch \
    && yum install -y --enablerepo=elasticsearch elasticsearch

USER elasticsearch

COPY elasticsearch.yml /etc/elasticsearch/

ENTRYPOINT /usr/share/elasticsearch/bin/elasticsearch
```

[Образ в репозитории](https://hub.docker.com/r/abeletskiyppr/elasticsearch)

```bash
$ curl -X GET localhost:9200/
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "-w7q9kLMR3ay19xAjSjpPw",
  "version" : {
    "number" : "7.15.2",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "93d5a7f6192e8a1a12e154a2b81bf6fa7309da0c",
    "build_date" : "2021-11-04T14:04:42.515624022Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

> В этом задании вы научитесь:
> - создавать и удалять индексы
> - изучать состояние кластера
> - обосновывать причину деградации доступности данных
> 
> Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
> и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:
> 
> | Имя | Количество реплик | Количество шард |
> |-----|-------------------|-----------------|
> | ind-1| 0 | 1 |
> | ind-2 | 1 | 2 |
> | ind-3 | 2 | 4 |
> 
> Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
> 
> Получите состояние кластера `elasticsearch`, используя API.
> 
> Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
> 
> Удалите все индексы.
> 
> **Важно**
> 
> При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
> иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

```bash
$ curl -X PUT -H "Content-Type: application/json" -d '{"settings":{"index":{"num
ber_of_replicas":0,"number_of_shards":1}}}' localhost:9200/ind-1
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-1"}

$ curl -X PUT -H "Content-Type: application/json" -d '{"settings":{"index":{"number
_of_replicas":1,"number_of_shards":2}}}' localhost:9200/ind-2
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-2"}

$ curl -X PUT -H "Content-Type: application/json" -d '{"settings":{"index":{"number_of_replicas":2,"number_of_shards":4}}}' localhost:9200/ind-3
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-3"}

$ curl -X GET localhost:9200/_cat/indices
green  open .geoip_databases krQaFiG4TU-cEqH1PxFmiA 1 0 43 0 40.9mb 40.9mb
green  open ind-1            nni4HZ1bTsqi8YNiYxa6AA 1 0  0 0   208b   208b
yellow open ind-3            LZuLfhNHRICCfwbXeFuSVA 4 2  0 0   832b   832b
yellow open ind-2            I7Y2aArcSr285XAbRYcwaQ 2 1  0 0   416b   416b

$ curl -X GET localhost:9200/_cat/health
1638808999 16:43:19 elasticsearch yellow 1 1 8 8 0 0 10 0 - 44.4%

$ curl -X DELETE localhost:9200/ind-3
{"acknowledged":true}

$ curl -X DELETE localhost:9200/ind-2
{"acknowledged":true}

$ curl -X DELETE localhost:9200/ind-1
{"acknowledged":true}
```

Индексы `ind-2`, `ind-3` и весь кластер целиком находятся в состоянии `yellow`, потому что используется single-node кластер, тогда как индексы требуют наличия 1 и 2 дополнительных реплик, которые просто негде размещать. 


## Задача 3

> В данном задании вы научитесь:
> - создавать бэкапы данных
> - восстанавливать индексы из бэкапов
> 
> Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.
> 
> Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
> данную директорию как `snapshot repository` c именем `netology_backup`.
> 
> **Приведите в ответе** запрос API и результат вызова API для создания репозитория.
> 
> Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
> 
> [Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
> состояния кластера `elasticsearch`.
> 
> **Приведите в ответе** список файлов в директории со `snapshot`ами.
> 
> Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
> 
> [Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
> кластера `elasticsearch` из `snapshot`, созданного ранее. 
> 
> **Приведите в ответе** запрос к API восстановления и итоговый список индексов.
> 
> Подсказки:
> - возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

```bash
$ docker exec 769a5af102b5b2b6a422287be4b9c385f25b2893c2dc9cf1051f2b1fd3d5b0ce bash -c "mkdir /var/lib/elasticsearch/snapshots"

$ curl -X PUT -H "Content-Type: application/json" -d '{"type":"fs","settings":{"loc
ation":"/var/lib/elasticsearch/snapshots"}}' localhost:9200/_snapshot/netology_backup
{"acknowledged":true}

$ curl -X PUT -H "Content-Type: application/json" -d '{"settings":{"index":{"number_of_replicas":0,"number_of_shards":1}}}' localhost:9200/test
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}

$ curl -X GET localhost:9200/_cat/indices
green open .geoip_databases 4cUj4sLLRtaxaDv0e1PPQg 1 0 43 0 40.9mb 40.9mb
green open test             FoBGl1mVR8uFFipNXHQi_Q 1 0  0 0   208b   208b

$ curl -X PUT localhost:9200/_snapshot/netology_backup/snapshot?wait_for_completion=true
{"snapshot":{"snapshot":"snapshot","uuid":"GruUQ8TWQ4605xRYY_mYpQ","repository":"netology_backup","version_id":7150299,"version":"7.15.2","indices":[".geoip_databases","test"],"data_streams":[],"include_global_state":true,"state":"SUCCESS","start_time":"2021-12-06T17:25:14.762Z","start_time_in_millis":1638811514762,"end_time":"2021-12-06T17:25:15.963Z","end_time_in_millis":1638811515963,"duration_in_millis":1201,"failures":[],"shards":{"total":2,"failed":0,"successful":2},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}

$ docker exec 4da3011108259cc0f0a7ba52da731ce0ce3897c9e5e66495df84e029cb65698c bash -c "ls -la /var/lib/elasticsearch/snapshots"
total 52
drwxr-sr-x 3 elasticsearch elasticsearch  4096 Dec  6 17:25 .
drwxr-s--- 1 elasticsearch elasticsearch  4096 Dec  6 17:17 ..
-rw-r--r-- 1 elasticsearch elasticsearch   826 Dec  6 17:25 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Dec  6 17:25 index.latest
drwxr-sr-x 4 elasticsearch elasticsearch  4096 Dec  6 17:25 indices
-rw-r--r-- 1 elasticsearch elasticsearch 27608 Dec  6 17:25 meta-GruUQ8TWQ4605xRYY_mYpQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch   435 Dec  6 17:25 snap-GruUQ8TWQ4605xRYY_mYpQ.dat

$ curl -X DELETE localhost:9200/test
{"acknowledged":true}

$ curl -X PUT -H "Content-Type: application/json" -d '{"settings":{"index":{"number_of_replicas":0,"number_of_shards":1}}}' localhost:9200/test-2
{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}

$ curl -X GET localhost:9200/_cat/indices
green open test-2           oO8N2EBIT6CujsbDRGPbFQ 1 0  0 0   208b   208b
green open .geoip_databases 4cUj4sLLRtaxaDv0e1PPQg 1 0 43 0 40.9mb 40.9mb

$ curl -X POST -H "Content-Type: application/json" -d '{"indices":"test"}' localhos
t:9200/_snapshot/netology_backup/snapshot/_restore
{"accepted":true}

$ curl -X GET localhost:9200/_cat/indices
green open test-2           oO8N2EBIT6CujsbDRGPbFQ 1 0  0 0   208b   208b
green open .geoip_databases 4cUj4sLLRtaxaDv0e1PPQg 1 0 43 0 40.9mb 40.9mb
green open test             QL0CzruRSq6fAp1OtNU5TQ 1 0  0 0   208b   208b
```
