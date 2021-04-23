# bashrc

祖传的 .bashrc 文件

## quick start

```bash
git clone https://github.com/bingzhangdai/bashrc.git
source bashrc/.bashrc
```

## key points

这份祖传的 bash 配置文件有什么特别之处呢?

* 快
  * 不像 oh-my-zsh 那样无脑的引入插件，引入新功能的时候以不拖慢 bash 性能为主
  * 所有功能尽量以 shell 脚本的方式实现，避免启动新进程（参考这里：[如何用最快的方式获取 git 分支](https://gist.github.com/bingzhangdai/dd4e283a14290c079a76c4ba17f19d69)）
* less is more
  * 所有定义的 alias，函数等都是 non-trivial 的，不会为了只是少打几个字符而定义一堆 alias，快捷键之类的增加记忆负担（例如不会有 `alias gc='git commit'`）
  * 不改变使用习惯，虽然增加了许多功能，但是不会增加太多记忆负担，只有直观并且被广泛使用的 alias/function/快捷键 才会被接受
* 为 WSL 优化（例如：在 WSL 上，自动补全会忽略 `*.dll` 作为可执行命令)

## features

* bash：大多数发行版自带 bash，并且服务器脚本都是跑的 bash 脚本

* 在便捷性，操作快捷上尽量与 zsh 靠近

* 素雅的命令提示符，最短的 prompt 提供尽可能多的信息

### 命令提示符

![prompt](images/prompt.png)

* 素雅：避免过于花哨的界面让人分不清主次

* 速度：即使在WSL上也不能卡（[原因](https://github.com/microsoft/WSL/issues/4197)），按回车一定要流畅

* 精简：不能占用太多空间，同屏/同行看到的信息越多工作效率越高，prompt 要尽可能的简短

* 兼容：prompt 只包含 ascii 字符，兼容老旧终端（cmd.exe）

设计思路来源于这篇文章：[你不需要花哨的命令提示符](https://zhuanlan.zhihu.com/p/51008087)，但更进一步。

#### 主题

如上图所示，但遵照习惯，root 用户，`$` 会显示成 `#`，为了醒目，用户名会显示成红色而不是绿色。

对于WSL用户，如果安装有多个发行版，hostname没有太多意义，因为hostname都是一样的，这时，hostname会替换成 Win10 商店里所安装的发行版的名字。

#### Fish 路径折叠

提示符只保留最后一级目录的完整名称，其他父目录全部折叠成一个字母的前缀，如果是隐藏目录，则显示前两个字母。这样可以避免路径过长时输入的命令被挤压到第二行。

#### 显示非零返回值

运行脚本时常常会因为疏忽而注意不到命令其实已经执行失败了，或者频繁地 `echo $?` 去检查返回值。这里如果上一个程序返回非 0，`$` 会显示为红色。

#### git branch

在 git 下工作时，会显示当前的分支名，分支名也会按照路径同样的方式折叠。

#### vi 模式

bash 默认为 vi 插入模式，故使用习惯和默认一致，按 ESC 会进入 vi 命令模式，按照vim的习惯，光标会变成实心方块。

（开启此模式需要把 `.inputrc` 拷贝到家目录，并重启终端。）