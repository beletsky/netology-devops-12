# Домашнее задание к занятию "3.1. Работа в терминале, лекция 1"

## 8. Настройка bash

- длина журнала history может быть задана в переменной окружения `HISTSIZE`. Она описана в абзаце раздела `Shell Variables` начиная со строки 792, а также в абзаце раздела `HISTORY` `man bash`, начиная со строки 2767. Если данная переменная не установлена, используется значение по умолчанию 500. Кроме того, можно задать это количество в переменной `history-size` библиотеки `readline`. Это описано в строке 2212 `man bash`. В последнем случае значение переменной окружения `HISTSIZE` использоваться не будет.
- "A value of `ignoreboth` is shorthand for `ignorespace` and `ignoredups`." Когда эта директива активна, в истории не сохраняются строки, начинающиеся с пробельного символа (за это отвечает директива `ignorespace`), а также при добавлении очередной команды из истории удаляются все предыдущие её использования (точные копии, директива `ignoredups`).

## 9. Использование {}

Фигурные скобки используются в следующих случаях:

- строка 241 - для создания групп команд;
- строка 1001 - для механизма brace expansion (создания строк на основе шаблонов);
- строка 1065 - для доступа к переменным окружения, в том числе массивам (строка 920);
- строка 1366 - для именования потоков перенаправления;
- строка 2003 - для задания формата даты в приглашении bash.

## 10. Массовое создание файлов

```
touch file{0..0100000}.txt
```

Попытка создания большого количества файлов с помощью brace expansion может приводить к ошибке `bash`: `Argument list too long`. Дело в том, что расширение выражения производится до запуска команды: выражение с фигурными скобками просто заменяется на полный сгенерированный список строк, разделённый пробелами. В итоге получается вызов команды `touch` с большим количеством аргументов, по одному аргументу на каждый файл. Однако длина строки с аргументами команды ограничена. Технически, это ограничение семейства функций `exec` ядра, в моём случае оно равно (`getconf ARG_MAX`) `2097152`. Насколько я понимаю, повысить данный лимит можно путём перекомпилирования ядра с новым значением, но более подробно я в этом вопросе уже не разбирался.

Интересно отметить, что данное ограничение не распространяется на внутренние команды `bash`, например: `echo file{0..0999999}.txt | less` отрабатывает успешно. 

## 11. Конструкция \[\[ \]\]

Данная конструкция используется для вычисления логических выражений. Её значением может быть только 0 или 1.

Например, конструкция `[[ -d /tmp ]]` возвратит 0, если в системе есть каталог `/tmp`, или 1 в противном случае.

## 12. Запуск bash из разных мест

```
mkdir /tmp/new_path_directory && ln -s /usr/bin/bash /tmp/new_path_directory && PATH=/tmp/new_path_directory:$PATH type -a bash
```

## 13. `batch` VS `at`

По стандарту POSIX [https://man7.org/linux/man-pages/man1/at.1p.html](), основные отличия `at` от `batch` следующие:

- `batch` запускается всегда без аргументов, и принимает команды для помещения в очередь со стандартного входного потока.
- Помещённые в очередь командой `batch` задачи начинают выполняться не сразу, а ожидают в очереди выполнения некоторых условий запуска, которые определяются конкретной реализацией. 
- `batch`  всегда использует в качестве времени запуска команды текущее время (но как минимум в реализации `Ubuntu` есть возможность использовать команду `at` для создания отложенных `batch` задач, см.ниже).

Данная группа команд использует понятие "очереди", которые кодируются одной буквой латинского алфавита. `at` по умолчанию помещает команды в очередь `a`, `batch` - в очередь `b`. Смысл, вкладываемый в название очереди, определяется конкретной реализацией.

В конкретной реализации `Ubuntu 20.04`, согласно `mat at`, поставленные в очередь командой `batch` задачи начинают выполняться только тогда, когда система не сильно загружена. Технически, это происходит когда `load average` (`cat /proc/loadavg`) окажется меньше значения, которое задаётся в настройках `atd`, по умолчанию 1.5.

В данной реализации, как указано в описании ключа `-q` команды `at`, очереди могут иметь названия от `a` до `z`, при этом чем дальше название очереди по алфавиту, тем с меньшим приоритетом (`niceness`) будут запускаться помещённые в эту очередь задачи.

При добавлении задач командой `at` можно указывать название очереди в виде большой буквы `A-Z`, в этом случае при достижении указанного времени запуска будет сэмулирован запуск указанной команды при помощи команды `batch` с помещением задачи в соответствующую очередь (уже со строчной буквой), то есть при запуске данной задачи будет учитываться текущий `load average` системы.