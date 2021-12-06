FROM centos:7

COPY elasticsearch.repo /etc/yum.repos.d/

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch \
    && yum install -y --enablerepo=elasticsearch elasticsearch

USER elasticsearch

COPY elasticsearch.yml /etc/elasticsearch/

ENTRYPOINT /usr/share/elasticsearch/bin/elasticsearch
