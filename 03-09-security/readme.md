# Домашнее задание к занятию "3.9. Элементы безопасности информационных систем"

> 1. Установите Bitwarden плагин для браузера. Зарегистрируйтесь и сохраните несколько паролей.

[Скриншот BitWarder](bitwarden.png).

> 2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.

Я не использую мобильный телефон, поэтому [настроил 2FA](betwarden-2fa.png) при помощи open-source приложения `WinAuth`, которое выглядит [вот так](winauth.png). 

> 3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.

Устанавливаем Apache2:
```shell
$ sudo apt install apache2
$ sudo a2enmod ssl
$ sudo systemctl restart apache2
```
Генерируем самоподписанный сертификат для `localhost`:
```shell
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \-keyout /etc/ssl/private/apache-selfsigned.key \-out /etc/ssl/certs/apache-selfsigned.crt \-subj "/C=RU/ST=Moscow/L=Moscow/O=Company Name/OU=Org/CN=localhost"
```
Указываем эти сертификаты в настройках в файле `/etc/apache2/sites-available/default-ssl.conf`:
```shell
SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
```
Разрешаем доступ к `https://localhost/`:
```shell
$ sudo a2ensite default-ssl.conf
$ sudo systemctl reload apache2
```
Проверяем доступ:
```shell
$ curl -v https://localhost/
*   Trying 127.0.0.1:443...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (OUT), TLS alert, unknown CA (560):
* SSL certificate problem: self signed certificate
* Closing connection 0
curl: (60) SSL certificate problem: self signed certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```
`curl` сообщает о том, что сертификаты самоподписанные, и доступ небезопасен. Отменим проверку сертификатов:
```shell
$ curl --insecure -v https://localhost/
*   Trying 127.0.0.1:443...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server accepted to use http/1.1
* Server certificate:
*  subject: C=RU; ST=Moscow; L=Moscow; O=Company Name; OU=Org; CN=localhost
*  start date: Sep 27 14:45:46 2021 GMT
*  expire date: Sep 27 14:45:46 2022 GMT
*  issuer: C=RU; ST=Moscow; L=Moscow; O=Company Name; OU=Org; CN=localhost
*  SSL certificate verify result: self signed certificate (18), continuing anyway.
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/7.68.0
> Accept: */*
> 
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Mon, 27 Sep 2021 14:52:19 GMT
< Server: Apache/2.4.41 (Ubuntu)
< Last-Modified: Mon, 27 Sep 2021 14:33:34 GMT
< ETag: "2aa6-5ccfafb576b47"
< Accept-Ranges: bytes
< Content-Length: 10918
< Vary: Accept-Encoding
< Content-Type: text/html
< 

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
...
...
...

```
Сайт доступен по протоколу HTTPS.

> 4. Проверьте на TLS уязвимости произвольный сайт в интернете.

```shell
$ ./testssl.sh -U --sneaky https://www.securitymedia.ru/


###########################################################
    testssl.sh       3.1dev from https://testssl.sh/dev/
    (b8bff80 2021-09-24 14:21:04 -- )

      This program is free software. Distribution and
             modification under GPLv2 permitted.
      USAGE w/o ANY WARRANTY. USE IT AT YOUR OWN RISK!

       Please file bugs @ https://testssl.sh/bugs/

###########################################################

 Using "OpenSSL 1.1.1f  31 Mar 2020" [~98 ciphers]
 on WORK:/usr/bin/openssl
 (built: "Apr 28 00:37:28 2021", platform: "debian-amd64")


Testing all IPv4 addresses (port 443): 90.156.201.86 90.156.201.87 90.156.201.79 90.156.201.84
---------------------------------------------------------------------------------------------
 Start 2021-09-27 17:03:40        -->> 90.156.201.86:443 (www.securitymedia.ru) <<--

 Further IP addresses:   90.156.201.79 90.156.201.87 90.156.201.84 2a00:15f8:a000:5:1:11:1:1b48 2a00:15f8:a000:5:1:13:1:1b48
                         2a00:15f8:a000:5:1:12:1:1b48 2a00:15f8:a000:5:1:14:1:1b48
 rDNS (90.156.201.86):   fe.shared.masterhost.ru.
 Service detected:       HTTP


 Testing vulnerabilities

 Heartbleed (CVE-2014-0160)                not vulnerable (OK), timed out
 CCS (CVE-2014-0224)                       not vulnerable (OK)
 Ticketbleed (CVE-2016-9244), experiment.  not vulnerable (OK), no session tickets
 ROBOT                                     not vulnerable (OK)
 Secure Renegotiation (RFC 5746)           OpenSSL handshake didn't succeed
 Secure Client-Initiated Renegotiation     not vulnerable (OK)
 CRIME, TLS (CVE-2012-4929)                not vulnerable (OK)
 BREACH (CVE-2013-3587)                    potentially NOT ok, "gzip" HTTP compression detected. - only supplied "/" tested
                                           Can be ignored for static pages or if no secrets in the page
 POODLE, SSL (CVE-2014-3566)               not vulnerable (OK)
 TLS_FALLBACK_SCSV (RFC 7507)              Downgrade attack prevention supported (OK)
 SWEET32 (CVE-2016-2183, CVE-2016-6329)    VULNERABLE, uses 64 bit block ciphers
 FREAK (CVE-2015-0204)                     not vulnerable (OK)
 DROWN (CVE-2016-0800, CVE-2016-0703)      not vulnerable on this host and port (OK)
                                           make sure you don't use this certificate elsewhere with SSLv2 enabled services
                                           https://censys.io/ipv4?q=766F64A87F1939D8A0FD4E71929591626257318CD5CB6129BE805498F181B5C3 could help you to find out
 LOGJAM (CVE-2015-4000), experimental      not vulnerable (OK): no DH EXPORT ciphers, no common prime detected
 BEAST (CVE-2011-3389)                     TLS1: ECDHE-RSA-AES128-SHA ECDHE-RSA-AES256-SHA DHE-RSA-AES128-SHA DHE-RSA-AES256-SHA AES128-SHA
                                                 AES256-SHA ECDHE-RSA-DES-CBC3-SHA EDH-RSA-DES-CBC3-SHA DES-CBC3-SHA
                                           VULNERABLE -- but also supports higher protocols  TLSv1.1 TLSv1.2 (likely mitigated)
 LUCKY13 (CVE-2013-0169), experimental     potentially VULNERABLE, uses cipher block chaining (CBC) ciphers with TLS. Check patches
 Winshock (CVE-2014-6321), experimental    not vulnerable (OK) - CAMELLIA or ECDHE_RSA GCM ciphers found
 RC4 (CVE-2013-2566, CVE-2015-2808)        no RC4 ciphers detected (OK)


 Done 2021-09-27 17:04:21 [  45s] -->> 90.156.201.86:443 (www.securitymedia.ru) <<--

...
...
...
```

> 5. Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.

Устанавливаем OpenSSH:
```shell
$ apt install openssh-server
$ systemctl start sshd.service
$ systemctl enable sshd.service
```
Проверяем доступ по паролю:
```shell
ssh andrey@172.20.22.247
The authenticity of host '172.20.22.247 (172.20.22.247)' can't be established.
ECDSA key fingerprint is SHA256:qA/5kAZEePsef1HuQFIYDIx8zVp2d41SH2Y4YX/XIiE.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '172.20.22.247' (ECDSA) to the list of known hosts.
andrey@172.20.22.247's password:
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-36-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

3 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Your Hardware Enablement Stack (HWE) is supported until April 2025.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

andrey@andrey-Virtual-Machine:~$
```
На другой системе генерируем ключи (я использовал алгоритм на основе эллиптических кривых ED25519):
```shell
ssh-keygen -t ed25519
```
Переносим публичный ключ `id_ed25519.pub` в файл `~/.ssh/authorized_keys`:
```shell
ssh-copy-id andrey@172.20.22.247
```
Проверяем доступ по ключу:
```shell
$ ssh andrey@172.20.22.247
Enter passphrase for key '/home/andrey/.ssh/ed25519':
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-36-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

3 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Your Hardware Enablement Stack (HWE) is supported until April 2025.
Last login: Mon Sep 27 18:06:52 2021 from 172.20.16.1
andrey@andrey-Virtual-Machine:~$
```
 
> 6. Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.

Переименовываем файл ключа:
```shell
mv ~/.ssh/id_ed25519 ~/.ssh/abeletsky
```
Создаём файл настроек клиента OpenSSH со следующим содержимым:
```shell
Host 172.20.22.247
    IdentityFile ~/.ssh/abeletsky
    IdentitiesOnly yes
    PreferredAuthentications publickey
    User andrey
```
Проверяем доступ при указании только имени хоста:
```shell
$ ssh 172.20.22.247
Enter passphrase for key '/home/andrey/.ssh/abeletsky':
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-36-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

3 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Your Hardware Enablement Stack (HWE) is supported until April 2025.
Last login: Mon Sep 27 18:45:52 2021 from 172.20.16.1
andrey@andrey-Virtual-Machine:~$
```

> 7. Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.

```shell
$ sudo tcpdump -i eth0 -c 100 -w 0001.pcap
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
100 packets captured
273 packets received by filter
0 packets dropped by kernel
```

[Скриншот WireShark](wireshark.png).