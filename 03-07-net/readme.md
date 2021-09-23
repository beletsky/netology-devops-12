# Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

> 1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?

В Linux:
```shell
$ ip -c addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 7a:c3:19:8b:cc:ba brd ff:ff:ff:ff:ff:ff
3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 76:4b:f9:73:7c:cc brd ff:ff:ff:ff:ff:ff
4: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
5: sit0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/sit 0.0.0.0 brd 0.0.0.0
6: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:2d:b9:20 brd ff:ff:ff:ff:ff:ff
    inet 172.29.235.171/20 brd 172.29.239.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::215:5dff:fe2d:b920/64 scope link
       valid_lft forever preferred_lft forever
```
Также в Linux можно использовать:
```shell
$ ifconfig -a
```
В Windows:
```commandline
> ipconfig /all
Windows IP Configuration

   Host Name . . . . . . . . . . . . : WORK
   Primary Dns Suffix  . . . . . . . :
   Node Type . . . . . . . . . . . . : Hybrid
   IP Routing Enabled. . . . . . . . : No
   WINS Proxy Enabled. . . . . . . . : No

Ethernet adapter vEthernet (Default Switch):

   Connection-specific DNS Suffix  . :
   Description . . . . . . . . . . . : Hyper-V Virtual Ethernet Adapter
   Physical Address. . . . . . . . . : 00-15-5D-EB-CB-2F
   DHCP Enabled. . . . . . . . . . . : No
   Autoconfiguration Enabled . . . . : Yes
   Link-local IPv6 Address . . . . . : fe80::d92b:8653:ca95:ca06%18(Preferred)
   IPv4 Address. . . . . . . . . . . : 172.20.16.1(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.240.0
   Default Gateway . . . . . . . . . :
   DHCPv6 IAID . . . . . . . . . . . : 301995357
   DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-25-BD-6D-FD-04-D4-C4-EF-76-6A
   DNS Servers . . . . . . . . . . . : fec0:0:0:ffff::1%1
                                       fec0:0:0:ffff::2%1
                                       fec0:0:0:ffff::3%1
   NetBIOS over Tcpip. . . . . . . . : Enabled

Ethernet adapter vEthernet (WSL):

   Connection-specific DNS Suffix  . :
   Description . . . . . . . . . . . : Hyper-V Virtual Ethernet Adapter #3
   Physical Address. . . . . . . . . : 00-15-5D-C2-1F-56
   DHCP Enabled. . . . . . . . . . . : No
   Autoconfiguration Enabled . . . . : Yes
   Link-local IPv6 Address . . . . . : fe80::2820:9aac:7aa7:e5d8%41(Preferred)
   IPv4 Address. . . . . . . . . . . : 172.29.224.1(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.240.0
   Default Gateway . . . . . . . . . :
   DHCPv6 IAID . . . . . . . . . . . : 687871325
   DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-25-BD-6D-FD-04-D4-C4-EF-76-6A
   DNS Servers . . . . . . . . . . . : fec0:0:0:ffff::1%1
                                       fec0:0:0:ffff::2%1
                                       fec0:0:0:ffff::3%1
   NetBIOS over Tcpip. . . . . . . . : Enabled
```
Также в Windows есть другие варианты, например:
```commandline
> netsh interface ipv4 show interfaces
> Get-NetIPInterface
```

> 2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?

Для этого используется протокол [Link Layer Discovery Protocol (LLDP)](http://xgu.ru/wiki/LLDP). Для его использования в Linux существует пакет lldpd, который добавляет в систему команды `lldpctl` и `lldpcli`.

> 3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.

Для этого используется технология [VLAN](http://xgu.ru/wiki/VLAN). Для Linux для работы с VLAN существует пакет [vlan](http://xgu.ru/wiki/VLAN_%D0%B2_Linux), добавляющий в систему команду `vconfig`. Однако в последнее время он постепенно заменяется пакетом `iproute`, поддерживающим с определённой версии работу с `VLAN`.

Интерфейсы `VLAN` создаются командой вида `vconfig add eth0 2` (или при помощи `ip link add ...` с рядом дополнительных параметров) с именем в формате `iface.VLAN`, например, `eth0.2`. Далее виртуальные интерфейсы настраиваются обычным образом (`ifconfig`, `route`, `ip`). Трафик через нижележащий (базовый) интерфейс `eth0` передаётся нетэгированным, а через виртуальные интерфейсы - тэгированным.

Для того чтобы виртуальные интерфейсы создавались при загрузке ОС, в Linux семейства Debian, например, можно задать их конфигурацию в файле `/etc/network/interfaces`. Пример автоматического создания `VLAN` на основе `eth0` с ID 1440 с указанием его ip-адреса и маски подсети:
```shell
auto eth0.1400
iface eth0.1400 inet static
        address 192.168.1.1
        netmask 255.255.255.0
        vlan_raw_device eth0
```

> 4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.

Для поддержки агрегирования каналов ядро Linux должно быть собрано со специальным модулем `bonding`. Для управления агрегацией используется пакет `ifenslave`.

Драйвер агрегирования поддерживает следующие режимы агрегирования (https://www.kernel.org/doc/Documentation/networking/bonding.txt):
- `balance_rr` - round-robin, пакеты передаются по очереди через каждый канал;
- `active-backup` - один из каналов находится "в резерве", и начинает использоваться только в случае проблем с другим каналом;
- `balance_xor` - используемый канал вычисляется для каждого пакета по заранее заданному правилу, удобно для тонкой настройки, какой канал для какого трафика использовать;
- `broadcast` - пакеты передаются сразу по всем каналам, существенно повышает надёжность доставки пакетов;
- `802.3ad` - реализация агрегации в соответствии со стандартом IEEE 802.3ad, близок по принципу работы к balance_xor;
- `balance-tlb` - канал для передачи выбирается исходя из текущей загрузки каналов передаваемыми данными;
- `balance-alb` - то же, что и balance-tlb, только учитывается загрузка каналов как на передачу, так и на приём.

На примере дистрибутива Ubuntu, агрегирование интерфейсов при загрузке ОС настраивается в файле `/etc/network/interfaces`, например для режима `active-backup`, следующим образом:
```shell
auto eth0
iface eth0 inet manual
    bond-master bond0
    bond-primary eth0

auto eth1
iface eth1 inet manual
    bond-master bond0
    
auto bond0
iface bond0 inet static
    address 192.168.1.10
    gateway 192.168.1.1
    netmask 255.255.255.0
    bond-mode active-backup
    bond-miimon 100
    bond-slaves none
```
Специфические для модуля `bonding` настройки указываются с префиксом `bond-`. В данном примере `bond-mode` задаёт режим агрегирования (резервирование), `bond-miimon` указывает интервал проверки доступности каналов.  

> 5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.

Для адресов хостов в подсети /29 отводится три бита, значит, возможных адресов будет 6 (восемь возможных значений от 0 до 7, исключая 0 для адреса сети и 7 для широковещательного адреса).

В подсети /24 может быть 2^5 = 32 различных подсетей /29 (пять бит, 29-24 = 5).

Адресом подсети /29 внутри 10.10.10.0/24 может быть любой адрес, последний октет которой делится на 8, например: 10.10.10.0/29, 10.10.10.8/29, ... , 10.10.10.248/29.

> 6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.

Стандарт [RFC6890](https://datatracker.ietf.org/doc/html/rfc6890) регулирует список подсетей специального назначения. Поскольку все подсети с назначением 'Private-Use' по условию уже заняты, придётся задействовать подсеть 100.64.0.0/10 с назначением 'Shared Address Space'. Так как нам нужно разместить в ней не более 50 хостов, достаточно будет использовать подсеть /26 (2^6 -2 = 64-2 = 62 хоста), например, 100.64.0.0/26.

Отдельно следует отметить, что решение, в которой каждый хост оказывается доступен в локальной сети по прямому ip-адресу, является верхом глупости :-) Необходимо использовать решения для разделения и фильтрации трафика, и сетевые решения для снижения требований к доступности хостов "извне".

> 7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?

Для Linux:
```shell
$ arp -v
Address                  HWtype  HWaddress           Flags Mask            Iface
_gateway                 ether   00:15:5d:eb:cb:2f   C                     eth0
Entries: 1	Skipped: 0	Found: 1
```
Чтобы очистить кэш полностью, можно либо удалить из него все записи по одной командной типа `arp -d _gateway`, либо использовать команду `ip -s -s neigh flush all`, или для каждого интерфейса выключить и снова включить ARP: `ip link set arp off dev eth0 ; ip link set arp on dev eth0`.

Для Windows:
```commandline
> arp -a -v
Interface: 127.0.0.1 --- 0x1
  Internet Address      Physical Address      Type
  224.0.0.22                                  static
  224.0.0.252                                 static
  230.0.0.1                                   static
  239.255.255.250                             static

Interface: 192.168.0.103 --- 0x3
  Internet Address      Physical Address      Type
  192.168.0.1           60-e3-27-ef-a2-78     dynamic
  192.168.0.100         00-00-00-00-00-00     invalid
  192.168.0.102         e4-a7-a0-99-37-3e     invalid
  192.168.0.103         00-00-00-00-00-00     invalid
  192.168.0.104         c8-5b-76-6b-eb-64     dynamic
...
```
Для полной очистки таблицы ARP в Windows можно использовать wildcard: `arp -d *`, для отдельного ip-адреса: `arp -d 192.168.0.104`.
