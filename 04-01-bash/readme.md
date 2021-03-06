# Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

> 1. Есть скрипт:
> 	```bash
> 	a=1
> 	b=2
> 	c=a+b
> 	d=$a+$b
> 	e=$(($a+$b))
> 	```
> 	* Какие значения переменным c,d,e будут присвоены?
> 	* Почему?

- `a` - значение `1`, которое может быть интерпретировано как строка или целое в зависимости от контекста; 
- `b` - значение `2` (с тем же замечанием, что и выше);
- `c` - строку `"a+b"` (без кавычек), потому что в данном случае `a` и `b` являются просто частью строки (для подстановки значения переменных перед их именем нужно ставить знак `$`);
- `d` - строку `1+2`, потому что будут подставлены значения переменных `a` и `b`, знак `+` будет интерпретирован как строка, и произойдёт конкатенация строк;
- `e` - число 3, потому что используется Arithmetic Expansion: производится вычисление арифметического выражения в скобках, и результат становится результатом конструкции `$((...))`.

> 2. На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным. В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
> 	```bash
> 	while ((1==1)
> 	do
> 	curl https://localhost:4757
> 	if (($? != 0))
> 	then
> 	date >> curl.log
> 	fi
> 	done
> 	```

В данном скрипте производится запись даты в файл, если проверка сервиса `https://localhost:4757` показывает его недоступность, но при доступности сервиса не делается ничего, и цикл продолжает выполняться. Чтобы скрипт закончил выполняться, когда сервис становится доступным, дополним его, например, так:
```bash
while ((1==1)
do
    curl https://localhost:4757
    if (($? != 0))
    then
        date >> curl.log
    else
        exit
    fi
done
```

> 3. Необходимо написать скрипт, который проверяет доступность трёх IP: 192.168.0.1, 173.194.222.113, 87.250.250.242 по 80 порту и записывает результат в файл log. Проверять доступность необходимо пять раз для каждого узла.

Для проверки доступности адреса по определённому порту используем команду вида `nc -zw1 192.168.0.1 80` (ключ `z` означает только провести проверку доступности, `-w1` используется для установки тайм-аута на случай, если проверка займёт долгое время). Результат выполнения команды используем для вывода в файл лога.

```bash
#!/usr/bin/env bash

hosts=(192.168.0.1 173.194.222.113 87.250.250.242)

for cur in {0..4}
do
  for host in ${hosts[@]}
  do
    if nc -zw1 $host 80
    then
      echo "$host accessible" >> log
    else
      echo "$host INACCESSIBLE" >> log
    fi
  done
done
```

> 4. Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается.
 
Модернизируем ветку `else` скрипта:

```bash
#!/usr/bin/env bash

hosts=(192.168.0.1 173.194.222.113 87.250.250.242)

for cur in {0..4}
do
  for host in ${hosts[@]}
  do
    if nc -zw1 $host 80
    then
      echo "$host accessible" >> log
    else
      echo "$host" > error
      exit
    fi
  done
done
```