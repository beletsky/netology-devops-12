# Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

> 1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP
> ```
> telnet route-views.routeviews.org
> Username: rviews
> show ip route x.x.x.x/32
> show bgp x.x.x.x/32
> ```

```shell
$ curl ifconfig.me
178.155.4.154
$ telnet route-views.routeviews.org
...
route-views>show ip route 178.155.4.154
Routing entry for 178.155.4.0/24
  Known via "bgp 6447", distance 20, metric 0
  Tag 8283, type external
  Last update from 94.142.247.3 7w0d ago
  Routing Descriptor Blocks:
  * 94.142.247.3, from 94.142.247.3, 7w0d ago
      Route metric is 0, traffic share count is 1
      AS Hops 3
      Route tag 8283
      MPLS label: none
route-views>show bgp 178.155.4.154
BGP routing table entry for 178.155.4.0/24, version 153014815
Paths: (23 available, best #20, table default)
  Not advertised to any peer
  Refresh Epoch 1
  20912 3257 3356 8359 29497
    212.66.96.126 from 212.66.96.126 (212.66.96.126)
      Origin IGP, localpref 100, valid, external
      Community: 3257:8070 3257:30515 3257:50001 3257:53900 3257:53902 20912:65004
      path 7FE0B5FF8CA8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  7660 2516 1299 8359 29497
    203.181.248.168 from 203.181.248.168 (203.181.248.168)
      Origin IGP, localpref 100, valid, external
      Community: 2516:1030 7660:9003
      path 7FE0F56F2650 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3267 1299 8359 29497
    194.85.40.15 from 194.85.40.15 (185.141.126.1)
      Origin IGP, metric 0, localpref 100, valid, external
      path 7FE11D097F88 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  53767 14315 6453 6453 3356 8359 29497
    162.251.163.2 from 162.251.163.2 (162.251.162.3)
      Origin IGP, localpref 100, valid, external
      Community: 14315:5000 53767:5000
      path 7FE1888F7908 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3356 8359 29497
    4.68.4.46 from 4.68.4.46 (4.69.184.201)
      Origin IGP, metric 0, localpref 100, valid, external
      Community: 3356:2 3356:100 3356:123 3356:507 3356:903 3356:2111 8359:5500 8359:55361 29497:29497
      path 7FE188157108 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  701 3356 8359 29497
    137.39.3.55 from 137.39.3.55 (137.39.3.55)
      Origin IGP, localpref 100, valid, external
      path 7FE0AEAB6D50 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  7018 3356 8359 29497
    12.0.1.63 from 12.0.1.63 (12.0.1.63)
      Origin IGP, localpref 100, valid, external
      Community: 7018:5000 7018:37232
      path 7FE15E60E0F8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3549 3356 8359 29497
    208.51.134.254 from 208.51.134.254 (67.16.168.191)
      Origin IGP, metric 0, localpref 100, valid, external
      Community: 3356:2 3356:100 3356:123 3356:507 3356:903 3356:2111 3549:2581 3549:30840 8359:5500 8359:55361 29497:29497
      path 7FE1217B0930 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  101 3356 8359 29497
    209.124.176.223 from 209.124.176.223 (209.124.176.223)
      Origin IGP, localpref 100, valid, external
      Community: 101:20100 101:20110 101:22100 3356:2 3356:100 3356:123 3356:507 3356:903 3356:2111 8359:5500 8359:55361 29497:29497
      Extended Community: RT:101:22100
      path 7FE16D1327C8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  1221 4637 3356 8359 29497
    203.62.252.83 from 203.62.252.83 (203.62.252.83)
      Origin IGP, localpref 100, valid, external
      path 7FE0C742FE80 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3333 8359 29497
    193.0.0.56 from 193.0.0.56 (193.0.0.56)
      Origin IGP, localpref 100, valid, external
      Community: 8359:5500 8359:55361 29497:29497
      path 7FE110B0B008 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  57866 1299 8359 29497
    37.139.139.17 from 37.139.139.17 (37.139.139.17)
      Origin IGP, metric 0, localpref 100, valid, external
      Community: 1299:20000 57866:100 57866:101 57866:501
      path 7FE177C16A48 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  852 3356 8359 29497
    154.11.12.212 from 154.11.12.212 (96.1.209.43)
      Origin IGP, metric 0, localpref 100, valid, external
      path 7FE104820FB0 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  20130 6939 8359 29497
    140.192.8.16 from 140.192.8.16 (140.192.8.16)
      Origin IGP, localpref 100, valid, external
      path 7FE1180F2C08 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 2
  3303 8359 29497
    217.192.89.50 from 217.192.89.50 (138.187.128.158)
      Origin IGP, localpref 100, valid, external
      Community: 3303:1004 3303:1006 3303:1030 3303:3056 8359:5500 8359:55361 29497:29497
      path 7FE16733DAE0 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3561 3910 3356 8359 29497
    206.24.210.80 from 206.24.210.80 (206.24.210.80)
      Origin IGP, localpref 100, valid, external
      path 7FE0D6E66018 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  4901 6079 8359 29497
    162.250.137.254 from 162.250.137.254 (162.250.137.254)
      Origin IGP, localpref 100, valid, external
      Community: 65000:10100 65000:10300 65000:10400
      path 7FE0A7781D38 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3257 3356 8359 29497
    89.149.178.10 from 89.149.178.10 (213.200.83.26)
      Origin IGP, metric 10, localpref 100, valid, external
      Community: 3257:8794 3257:30043 3257:50001 3257:54900 3257:54901
      path 7FDFFF4E5598 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  49788 12552 8359 29497
    91.218.184.60 from 91.218.184.60 (91.218.184.60)
      Origin IGP, localpref 100, valid, external
      Community: 12552:12000 12552:12100 12552:12101 12552:22000
      Extended Community: 0x43:100:1
      path 7FE16A552888 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 4
  8283 8359 29497
    94.142.247.3 from 94.142.247.3 (94.142.247.3)
      Origin IGP, metric 0, localpref 100, valid, external, best
      Community: 8283:1 8283:101 8359:5500 8359:55361 29497:29497
      unknown transitive attribute: flag 0xE0 type 0x20 length 0x18
        value 0000 205B 0000 0000 0000 0001 0000 205B
              0000 0005 0000 0001
      path 7FE09CA86DE0 RPKI State not found
      rx pathid: 0, tx pathid: 0x0
  Refresh Epoch 1
  2497 8359 29497
    202.232.0.2 from 202.232.0.2 (58.138.96.254)
      Origin IGP, localpref 100, valid, external
      path 7FE0C9837D40 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  1351 8359 29497
    132.198.255.253 from 132.198.255.253 (132.198.255.253)
      Origin IGP, localpref 100, valid, external
      path 7FE117BEDB00 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  6939 8359 29497
    64.71.137.241 from 64.71.137.241 (216.218.252.164)
      Origin IGP, localpref 100, valid, external
      path 7FE0DC69D2F8 RPKI State not found
      rx pathid: 0, tx pathid: 0
```

> 2. Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.

Начальное состояние системы:
```shell
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:00:65:0a brd ff:ff:ff:ff:ff:ff
    inet 172.20.22.247/20 brd 172.20.31.255 scope global dynamic noprefixroute eth0
       valid_lft 46311sec preferred_lft 46311sec
    inet6 fe80::d8b0:16e3:42ec:190d/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
$ ip route
default via 172.20.16.1 dev eth0 proto dhcp metric 100 
169.254.0.0/16 dev eth0 scope link metric 1000 
172.20.16.0/20 dev eth0 proto kernel scope link src 172.20.22.247 metric 100 
```
Добавляем dummy интерфейс:
```shell
$ modprobe -v dummy
insmod /lib/modules/5.11.0-36-generic/kernel/drivers/net/dummy.ko numdummies=0
$ ip link add dummy0 type dummy
$ ip link add dummy0 type dummy
$ ip link set dummy0 up
```
В результате получаем:
```shell
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:00:65:0a brd ff:ff:ff:ff:ff:ff
    inet 172.20.22.247/20 brd 172.20.31.255 scope global dynamic noprefixroute eth0
       valid_lft 46029sec preferred_lft 46029sec
    inet6 fe80::d8b0:16e3:42ec:190d/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether e2:18:54:34:f2:b1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.13.42/24 scope global dummy0
       valid_lft forever preferred_lft forever
    inet6 fe80::e018:54ff:fe34:f2b1/64 scope link 
       valid_lft forever preferred_lft forever
$ ip route
default via 172.20.16.1 dev eth0 proto dhcp metric 100 
169.254.0.0/16 dev eth0 scope link metric 1000 
172.20.16.0/20 dev eth0 proto kernel scope link src 172.20.22.247 metric 100 
192.168.13.0/24 dev dummy0 proto kernel scope link src 192.168.13.42 
```
Допустим, мы хотим весь трафик для узла 192.168.13.41/32 вывести наружу через интерфейс eth0. В текущей конфигурации он недоступен, так как пакеты отправляются в dummy интерфейс, например:
```shell
$ traceroute 192.168.13.41
traceroute to 192.168.13.41 (192.168.13.41), 30 hops max, 60 byte packets
 1  * * *
 2  * * *
 3  * * *
...
```
Добавляем маршрут:
```shell
$ sudo ip route add 192.168.13.41/32 dev eth0
$ ip route
default via 172.20.16.1 dev eth0 proto dhcp metric 100 
169.254.0.0/16 dev eth0 scope link metric 1000 
172.20.16.0/20 dev eth0 proto kernel scope link src 172.20.22.247 metric 100 
192.168.13.0/24 dev dummy0 proto kernel scope link src 192.168.13.42
192.168.13.41 dev eth0 scope link  
```
Проверяем результат:
```shell
$ traceroute 192.168.13.41
traceroute to 192.168.13.41 (192.168.13.41), 30 hops max, 60 byte packets
 1  andrey-Virtual-Machine (172.20.22.247)  3072.478 ms !H  3072.463 ms !H  3072.461 ms !H
```
Пакет на адрес 192.168.13.41 теперь уходит на хостовую машину, которая ожидаемо отвечает (`!H`), что она не знает, куда отправлять пакеты для адреса `192.168.13.41`. 

> 3. Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.

```shell
$ ss -lt
State     Recv-Q    Send-Q       Local Address:Port                 Peer Address:Port   Process
LISTEN    0         1024             127.0.0.1:56261                     0.0.0.0:*
LISTEN    0         1024             127.0.0.1:51176                     0.0.0.0:*
LISTEN    0         4096                     *:mysql                           *:*
LISTEN    0         4096                     *:3307                            *:*
LISTEN    0         4096                     *:http-alt                        *:*
LISTEN    0         4096                     *:tproxy                          *:*
LISTEN    0         4096                     *:8082                            *:*
LISTEN    0         4096                     *:8051                            *:*
LISTEN    0         4096                     *:8443                            *:*
LISTEN    0         4096                     *:zabbix-trapper                  *:*
```

На данной системе запущено (под докером) два сервера MySQL, слушающих на портах 3306 (mysql) и 3307, несколько серверов nginx на портах 8080 (http-alt), 8081 (tproxy), 8082, 8443, а также система мониторинга Zabbix, использующая порты 8051 (веб-интерфейс) и 10051 (для сбора данных).

> 4. Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?

```shell
$ ss -ua
State   Recv-Q  Send-Q          Local Address:Port       Peer Address:Port    Process  
UNCONN  0       0                     0.0.0.0:631             0.0.0.0:*                
UNCONN  0       0                   127.0.0.1:8125            0.0.0.0:*                
UNCONN  0       0               127.0.0.53%lo:domain          0.0.0.0:*                
ESTAB   0       0          172.20.22.247%eth0:bootpc      172.20.16.1:bootps           
UNCONN  0       0                     0.0.0.0:mdns            0.0.0.0:*                
UNCONN  0       0                     0.0.0.0:34234           0.0.0.0:*                
UNCONN  0       0                        [::]:mdns               [::]:*                
UNCONN  0       0                        [::]:39209              [::]:*     
```
В данном случае происходит процесс взаимодействия хоста с сервером DHCP на хостовой машине (172.20.16.1:bootps). Остальные соединения уже завершились. В частности, ранее выполнялись некие запросы, связанные с DNS-серверами (lo:domain - 53 порт, 0.0.0.0:mdns - 5353 порт), а также поиск службы печати по протоколу IPP (0.0.0.0:631).

> 5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали. 

Нарисовал на [диаграмме](intranet.drawio) мою домашнюю сеть. В ней присутствует одно отдельно стоящее помещение (Помещение 2), в котором поднята отдельная сеть Wi-Fi, а также несколько отдельных комнат, в которых различные устройства подключены к сети проводами.