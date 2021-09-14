# Домашнее задание к занятию "3.5. Файловые системы"

> 1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

Основная идея `sparse files` - не писать пустые части файла на диск, а просто помечать в метаданных файла места, не содержащие никаких данных (заполненных `\0`). Для больших, но практически пустых файлов это позволяет существенно экономить место на диске и ускорять доступ к содержимому.

> 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Не могут.

Информация о правах доступа и владельцах содержится в структуре данных о файле для каждого `inode`. Поскольку `hard link` является всего лишь ссылкой на *тот же самый* inode, данная информация будет той же, что и у исходного файла.

Хотел бы отметить, что, на мой взгляд, не очень корректно называть уже существующие файлы "жёсткой ссылкой". Технически, мы можем _создать_ "жёсткую ссылку", указав уже существующий файл, но после её создания оба имени ссылаются на один и то же inode и принципиально ничем не отличаются друг от друга. Оба имени являются полноценными файлами, ни один из них не является какой-либо "ссылкой" на другой. 

> 3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:
> 
>     ```bash
>     Vagrant.configure("2") do |config|
>       config.vm.box = "bento/ubuntu-20.04"
>       config.vm.provider :virtualbox do |vb|
>         lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
>         lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
>         vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
>         vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
>         vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
>         vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
>       end
>     end
>     ```
> 
>     Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

Я работаю в виртуальной машине под Hyper-V, в ней простым путём не получилось добавить диски размером 2,5 Гб, поэтому я взял размер 3 Гб.

```bash
$ lsblk
```
```
sdb      8:16   0     3G  0 disk 
sdc      8:32   0     3G  0 disk 
```

> 4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

Лог выполнения команды `sudo fdisk /dev/sdb`:
```
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x70b256b8.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-6291455, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-6291455, default 6291455): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 2
First sector (4196352-6291455, default 4196352): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-6291455, default 6291455): 

Created a new partition 2 of type 'Linux' and of size 1023 MiB.

Command (m for help): p
Disk /dev/sdb: 3 GiB, 3221225472 bytes, 6291456 sectors
Disk model: Virtual Disk    
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: dos
Disk identifier: 0x70b256b8

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 6291455 2095104 1023M 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

> 5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

Лог выполнения команды `sudo sfdisk -d /dev/sdb | sudo sfdisk /dev/sdc`:
```
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 3 GiB, 3221225472 bytes, 6291456 sectors
Disk model: Virtual Disk    
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x70b256b8.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 1023 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x70b256b8

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 6291455 2095104 1023M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

Проверяем итоговый результат командой `lsblk`:
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
...
sdb      8:16   0     3G  0 disk 
├─sdb1   8:17   0     2G  0 part 
└─sdb2   8:18   0  1023M  0 part 
sdc      8:32   0     3G  0 disk 
├─sdc1   8:33   0     2G  0 part 
└─sdc2   8:34   0  1023M  0 part
... 
```

> 6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

```bash
$ sudo mdadm -vC /dev/md0 -l 1 -n 2 /dev/sdb1 /dev/sdc1
```
```
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

> 7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

```bash
$ sudo mdadm -vC /dev/md1 -l 0 -n 2 /dev/sdb2 /dev/sdc2
```
```
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```
В результате команда `lsblk` показывает следующий список устройств:
```
NAME    MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
...
sdb       8:16   0     3G  0 disk  
├─sdb1    8:17   0     2G  0 part  
│ └─md0   9:0    0     2G  0 raid1 
└─sdb2    8:18   0  1023M  0 part  
  └─md1   9:1    0     2G  0 raid0 
sdc       8:32   0     3G  0 disk  
├─sdc1    8:33   0     2G  0 part  
│ └─md0   9:0    0     2G  0 raid1 
└─sdc2    8:34   0  1023M  0 part  
  └─md1   9:1    0     2G  0 raid0
... 
```

> 8. Создайте 2 независимых PV на получившихся md-устройствах.

```bash
$ sudo pvcreate /dev/md0 /dev/md1 && sudo pvdisplay
```
```
 Physical volume "/dev/md0" successfully created.
  Physical volume "/dev/md1" successfully created.
  "/dev/md0" is a new physical volume of "<2,00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/md0
  VG Name               
  PV Size               <2,00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               QdgWOU-66Kp-HdCp-iH78-YFMJ-BYGh-BArrIi
   
  "/dev/md1" is a new physical volume of "1,99 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/md1
  VG Name               
  PV Size               1,99 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               069dKa-3Q9t-G74F-cTpL-HL5u-f3n2-fGJTwc
```

> 9. Создайте общую volume-group на этих двух PV.

```bash
$ sudo vgcreate -v raidvg /dev/md0 /dev/md1 && sudo vgdisplay
```
```
  Wiping signatures on new PV /dev/md0.
  Wiping signatures on new PV /dev/md1.
  Adding physical volume '/dev/md0' to volume group 'raidvg'
  Adding physical volume '/dev/md1' to volume group 'raidvg'
  Creating directory "/etc/lvm/archive"
  Archiving volume group "raidvg" metadata (seqno 0).
  Creating directory "/etc/lvm/backup"
  Creating volume group backup "/etc/lvm/backup/raidvg" (seqno 1).
  Volume group "raidvg" successfully created
  --- Volume group ---
  VG Name               raidvg
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <3,99 GiB
  PE Size               4,00 MiB
  Total PE              1021
  Alloc PE / Size       0 / 0   
  Free  PE / Size       1021 / <3,99 GiB
  VG UUID               DZDK0l-3KjT-r62H-Asfz-yZQ5-yl8E-uRVJqy
```

> 10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

```bash
$ sudo lvcreate -L 100m raidvg /dev/md1
```
```
Logical volume "lvol0" created.
```
```bash
$ lsblk
```
```
NAME               MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
...
sdb                  8:16   0     3G  0 disk  
├─sdb1               8:17   0     2G  0 part  
│ └─md0              9:0    0     2G  0 raid1 
└─sdb2               8:18   0  1023M  0 part  
  └─md1              9:1    0     2G  0 raid0 
    └─raidvg-lvol0 253:0    0   100M  0 lvm   
sdc                  8:32   0     3G  0 disk  
├─sdc1               8:33   0     2G  0 part  
│ └─md0              9:0    0     2G  0 raid1 
└─sdc2               8:34   0  1023M  0 part  
  └─md1              9:1    0     2G  0 raid0 
    └─raidvg-lvol0 253:0    0   100M  0 lvm   
... 
```

> 11. Создайте `mkfs.ext4` ФС на получившемся LV.

```bash
$ sudo mkfs.ext4 -v /dev/raidvg/lvol0
```
```
mke2fs 1.45.5 (07-Jan-2020)
fs_types for mke2fs.conf resolution: 'ext4', 'small'
Discarding device blocks: done                            
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=128 blocks, Stripe width=256 blocks
25600 inodes, 25600 blocks
1280 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=27262976
1 block group
32768 blocks per group, 32768 fragments per group
25600 inodes per group

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```

> 12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

```bash
$ sudo mkdir /tmp/new && sudo mount /dev/raidvg/lvol0 /tmp/new
```

> 13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

```bash
$ sudo wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
```
```
--2021-09-14 15:43:14--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 21061448 (20M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                     100%[====================================================================>]  20,08M  7,43MB/s    in 2,7s    

2021-09-14 15:43:16 (7,43 MB/s) - ‘/tmp/new/test.gz’ saved [21061448/21061448]
```
```bash
$ ll /tmp/new
```
```
total 20592
drwxr-xr-x  3 root root     4096 сен 14 15:43 ./
drwxrwxrwt 19 root root     4096 сен 14 15:42 ../
drwx------  2 root root    16384 сен 14 15:40 lost+found/
-rw-r--r--  1 root root 21061448 сен 14 12:21 test.gz
```

> 14. Прикрепите вывод `lsblk`.

```bash
$ lsblk
```
```
NAME               MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
...
sdb                  8:16   0     3G  0 disk  
├─sdb1               8:17   0     2G  0 part  
│ └─md0              9:0    0     2G  0 raid1 
└─sdb2               8:18   0  1023M  0 part  
  └─md1              9:1    0     2G  0 raid0 
    └─raidvg-lvol0 253:0    0   100M  0 lvm   
sdc                  8:32   0     3G  0 disk  
├─sdc1               8:33   0     2G  0 part  
│ └─md0              9:0    0     2G  0 raid1 
└─sdc2               8:34   0  1023M  0 part  
  └─md1              9:1    0     2G  0 raid0 
    └─raidvg-lvol0 253:0    0   100M  0 lvm   
...   
```

> 15. Протестируйте целостность файла:
> 
>     ```bash
>     root@vagrant:~# gzip -t /tmp/new/test.gz
>     root@vagrant:~# echo $?
>     0
>     ```

```bash
$ sudo gzip -t /tmp/new/test.gz ; echo $?
```
```
0
```

> 16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

```bash
$ sudo pvmove -v /dev/md1 /dev/md0
```
```
  Executing: /sbin/modprobe dm-mirror
  Archiving volume group "raidvg" metadata (seqno 4).
  Creating logical volume pvmove0
  activation/volume_list configuration setting not defined: Checking only host tags for raidvg/lvol0.
  Moving 25 extents of logical volume raidvg/lvol0.
  activation/volume_list configuration setting not defined: Checking only host tags for raidvg/lvol0.
  Creating raidvg-pvmove0
  Loading table for raidvg-pvmove0 (253:1).
  Loading table for raidvg-lvol0 (253:0).
  Suspending raidvg-lvol0 (253:0) with device flush
  Resuming raidvg-pvmove0 (253:1).
  Resuming raidvg-lvol0 (253:0).
  Creating volume group backup "/etc/lvm/backup/raidvg" (seqno 5).
  activation/volume_list configuration setting not defined: Checking only host tags for raidvg/pvmove0.
  Checking progress before waiting every 15 seconds.
  /dev/md1: Moved: 12,00%
  /dev/md1: Moved: 100,00%
  Polling finished successfully.
```
```bash
$ lsblk
```
```
NAME               MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
...
sdb                  8:16   0     3G  0 disk  
├─sdb1               8:17   0     2G  0 part  
│ └─md0              9:0    0     2G  0 raid1 
│   └─raidvg-lvol0 253:0    0   100M  0 lvm   /tmp/new
└─sdb2               8:18   0  1023M  0 part  
  └─md1              9:1    0     2G  0 raid0 
sdc                  8:32   0     3G  0 disk  
├─sdc1               8:33   0     2G  0 part  
│ └─md0              9:0    0     2G  0 raid1 
│   └─raidvg-lvol0 253:0    0   100M  0 lvm   /tmp/new
└─sdc2               8:34   0  1023M  0 part  
  └─md1              9:1    0     2G  0 raid0
... 
```

> 17. Сделайте `--fail` на устройство в вашем RAID1 md.

```bash
$ sudo mdadm -v /dev/md0 --fail /dev/sdc1
```
```
mdadm: set /dev/sdc1 faulty in /dev/md0
```

> 18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

```bash
$ dmesg -T
```
```
...
[Вт сен 14 15:56:19 2021] md/raid1:md0: Disk failure on sdc1, disabling device.
                               md/raid1:md0: Operation continuing on 1 devices.
```

> 19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:
> 
>     ```bash
>     root@vagrant:~# gzip -t /tmp/new/test.gz
>     root@vagrant:~# echo $?
>     0
>     ```

```bash
$ sudo gzip -t /tmp/new/test.gz ; echo $?
```
```
0
```

> 20. Погасите тестовый хост, `vagrant destroy`.