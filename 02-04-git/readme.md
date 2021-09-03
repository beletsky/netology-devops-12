# Домашнее задание к занятию «2.4. Инструменты Git»


## 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.

> `aefead2207ef7e2aa5dc81a34aedf0cad4c32545`
> 
> Update CHANGELOG.md

```
@git show -s aefea
```
```
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
Date:   Thu Jun 18 10:29:58 2020 -0400

    Update CHANGELOG.md
```

## 2. Какому тегу соответствует коммит 85024d3?

> `v0.12.23`

```
git show --oneline -s 85024d3
```
```
85024d310 (tag: v0.12.23) v0.12.23
```

## 3. Сколько родителей у коммита b8d720? Напишите их хеши.

> Два:
> 
>`56cd7859e05c36c06b56d013b55a252d0bb7e158`
>
> `9ea88f22fc6269854151c571162c5bcf958bee2b`

```
git log -1 --no-abbrev b8d720
```
```
commit b8d720f8340221f2146e4e4870bf2ee0bc48f2d5
Merge: 56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b
Author: Chris Griggs <cgriggs@hashicorp.com>
Date:   Tue Jan 21 17:45:48 2020 -0800

    Merge pull request #23916 from hashicorp/cgriggs01-stable

    [Cherrypick] community links
```

## 4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.

В команде вывода лога исключим коммит с тэгом `v0.12.24`, взяв предыдущий, потому что в формулировке задачи требуются только коммиты _между данными тэгами.

```
git log --format="%H %s" v0.12.23..v0.12.24^
```
> ```
> b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
> 3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
> 6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
> 5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
> 06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
> d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
> 4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
> dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
> 225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release
> ```

## 5. Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы).

> `8c928e835`

Ищем файл, в котором определена искомая функция.

```
git grep -P "func\\s+providerSource\("
```
```
provider_source.go:func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {
```

Смотрим историю изменений функции в данном файле.

```
git log --no-patch --oneline --left-right -L :providerSource:provider_source.go
```
```
> 5af1e6234 main: Honor explicit provider_installation CLI config when present
> 92d6a30bb main: skip direct provider installation for providers available locally
> 8c928e835 main: Consult local directories as potential mirrors of providers
```

На всякий случай проверяем, что в истории изменений данная функция не появлялась в других коммитах.

```
git log --oneline -G"func\s+providerSource\("
```
```
5af1e6234 main: Honor explicit provider_installation CLI config when present
8c928e835 main: Consult local directories as potential mirrors of providers
```

## 6. Найдите все коммиты в которых была изменена функция globalPluginDirs.

Ищем файл, в котором определена указанная функция.

```
git grep -P "globalPluginDirs"
```
```
commands.go:            GlobalPluginDirs: globalPluginDirs(),
commands.go:    helperPlugins := pluginDiscovery.FindPlugins("credentials", globalPluginDirs())
internal/command/cliconfig/config_unix.go:              // FIXME: homeDir gets called from globalPluginDirs during init, before
plugins.go:// globalPluginDirs returns directories that should be searched for
plugins.go:func globalPluginDirs() []string {
```

Получаем историю изменений данной функции.

```
git log --no-patch --oneline --left-right -L :globalPluginDirs:plugins.go
```
> ```
> > 78b122055 Remove config.go and update things using its aliases
> > 52dbf9483 keep .terraform.d/plugins for discovery
> > 41ab0aef7 Add missing OS_ARCH dir to global plugin paths
> > 66ebff90c move some more plugin search path logic to command
> > 8364383c3 Push plugin discovery down into command package
> ```

## 7. Кто автор функции synchronizedWriters?

> Author: Martin Atkins <mart@degeneration.co.uk>

Ищем файл, который содержит данную функцию.

```
git grep -P "synchronizedWriters"
```

Файла с такой функцией нет, значит, она была удалена в процессе разработки. Ищем по истории коммиты, в которых были строки с названием функции.

```
git log -S'synchronizedWriters'
```
```
bdfea50cc remove unused
fd4f7eb0b remove prefixed io
5ac311e2a main: synchronize writes to VT100-faker on Windows
```

Убеждаемся, что функция была создана в самом раннем коммите.

```
git show 5ac311e2a
```
```
commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5
Author: Martin Atkins <mart@degeneration.co.uk>
Date:   Wed May 3 16:25:41 2017 -0700

    main: synchronize writes to VT100-faker on Windows

    We use a third-party library "colorable" to translate VT100 color
    sequences into Windows console attribute-setting calls when Terraform is
    running on Windows.

    colorable is not concurrency-safe for multiple writes to the same console,
    because it writes to the console one character at a time and so two
    concurrent writers get their characters interleaved, creating unreadable
    garble.

    Here we wrap around it a synchronization mechanism to ensure that there
    can be only one Write call outstanding across both stderr and stdout,
    mimicking the usual behavior we expect (when stderr/stdout are a normal
    file handle) of each Write being completed atomically.

diff --git a/main.go b/main.go
index b94de2ebc..237581200 100644
--- a/main.go
+++ b/main.go
@@ -258,6 +258,15 @@ func copyOutput(r io.Reader, doneCh chan<- struct{}) {
        if runtime.GOOS == "windows" {
                stdout = colorable.NewColorableStdout()
                stderr = colorable.NewColorableStderr()
+
+               // colorable is not concurrency-safe when stdout and stderr are the
+               // same console, so we need to add some synchronization to ensure that
+               // we can't be concurrently writing to both stderr and stdout at
+               // once, or else we get intermingled writes that create gibberish
+               // in the console.
+               wrapped := synchronizedWriters(stdout, stderr)
+               stdout = wrapped[0]
+               stderr = wrapped[1]
        }

        var wg sync.WaitGroup
diff --git a/synchronized_writers.go b/synchronized_writers.go
new file mode 100644
index 000000000..2533d1316
--- /dev/null
+++ b/synchronized_writers.go
@@ -0,0 +1,31 @@
+package main
+
+import (
+       "io"
+       "sync"
+)
+
+type synchronizedWriter struct {
+       io.Writer
+       mutex *sync.Mutex
+}
+
+// synchronizedWriters takes a set of writers and returns wrappers that ensure
+// that only one write can be outstanding at a time across the whole set.
+func synchronizedWriters(targets ...io.Writer) []io.Writer {
+       mutex := &sync.Mutex{}
+       ret := make([]io.Writer, len(targets))
+       for i, target := range targets {
+               ret[i] = &synchronizedWriter{
+                       Writer: target,
+                       mutex:  mutex,
+               }
+       }
+       return ret
+}
+
+func (w *synchronizedWriter) Write(p []byte) (int, error) {
+       w.mutex.Lock()
+       defer w.mutex.Unlock()
+       return w.Writer.Write(p)
+}
```