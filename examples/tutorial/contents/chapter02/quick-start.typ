= 十分钟生成第一份论文 <chapter-02>

== 准备环境

=== 首先安装 VS Code

打开 #link("https://code.visualstudio.com/")[VSCode (https://code.visualstudio.com)] 官网。

#figure(
  image("imgs/1-download-vscode.png", width: 80%),
  caption: [VSCode 官网页面],
)

网页会自动检测并匹配合适的安装包，直接点击网页中间的下载按钮即可开始下载，下载完成后双击安装包进行安装。

#figure(
  image("imgs/2-install-vscode.png", width: 80%),
  caption: [VSCode 安装程序：协议条款页面],
)

同意协议并点击下一步。

#figure(
  image("imgs/3-install-vscode.png", width: 80%),
  caption: [VSCode 安装程序：额外选项],
)

根据需求自行勾选/取消选项，然后点击下一步。

#figure(
  image("imgs/4-install-vscode.png", width: 80%),
  caption: [VSCode 安装程序：准备安装],
)

检查安装程序将要执行的任务，然后点击安装。

#figure(
  image("imgs/5-install-vscode.png", width: 80%),
  caption: [VSCode 安装程序：安装中],
)

安装程序执行安装，耐心等待安装完成。

#figure(
  image("imgs/6-install-vscode.png", width: 80%),
  caption: [VSCode 安装程序：安装完成],
)

安装完成后，点击完成。

=== 安装 Tinymist 插件

#figure(
  image("imgs/7-install-tinymist.png", width: 80%),
  caption: [VSCode 初始界面],
)

点击左侧的插件栏或按下`Ctrl+Shift+X`快捷键，打开插件栏。

#figure(
  image("imgs/8-install-tinymist.png", width: 80%),
  caption: [VSCode 安装 Tinymist 插件],
)

在搜索栏输入 Tinymist 并按下回车，找到 Tinymist Typst 插件并点击安装。

#figure(
  image("imgs/9-install-tinymist.png", width: 80%),
  caption: [VSCode Tinymist 插件安装完成],
) <fig-tinymist-install-done>

如@fig-tinymist-install-done 所示说明 Tinymist 插件安装成功。

=== 下载 Typst CLI 并将其添加到 PATH 环境变量 <sec-typst-cli-path>

打开 #link("https://github.com/typst/typst")[Typst (https://github.com/typst/typst)] 项目主页。

#figure(
  image("imgs/10-download-typst-cli.png", width: 70%),
  caption: [Typst 项目主页],
)

找到 `Releases` 并点击进入 Releases 页面，或直接打开 #link("https://github.com/typst/typst/releases")[Typst Releases (https://github.com/typst/typst/releases)]。

#figure(
  image("imgs/11-download-typst-cli.png", width: 70%),
  caption: [Typst CLI Releases 发布页面],
)

根据系统下载合适的版本：

· x86_64 对应 64 位 x86 架构 CPU；aarch64 对应 64 位 ARM 架构；armv7 对应 32位 ARM 架构；riscv64gc 对应 64 位 RISC-V 架构。

· apple-darwin 对应 macOS 系统；pc-windows-msvc 对应 Windows 系统；unknown-linux 对应 Linux 系统。

这里演示使用的是 typst-x86_64-pc-windows-msvc.zip。

#figure(
  image("imgs/12-unzip-typst-cli.png", width: 80%),
  caption: [解压 Typst CLI],
)

下载完成后，解压到文件夹，并记下文件夹路径（也就是 typst.exe 所在路径）。这里演示是解压到 `D:\Typst`。

#figure(
  image("imgs/13-sys-env-var.png", width: 80%),
  caption: [在 Windows 开始菜单中搜索环境变量],
)

在 Windows 开始菜单中搜索环境变量，一般匹配项第一个即是编辑环境变量。

#figure(
  image("imgs/14-sys-env-var.png", width: 60%),
  caption: [系统属性窗口],
)

点击打开后弹出系统属性窗口，再次点击右下角环境变量按钮。

#figure(
  image("imgs/15-edit-sys-env-var.png", width: 70%),
  caption: [环境变量窗口],
)

找到系统变量下的 Path 变量，选中并点击编辑按钮（或双击）弹出环境变量编辑窗口。

#figure(
  image("imgs/16-edit-sys-env-var.png", width: 70%),
  caption: [环境变量编辑窗口],
)

点击新建按钮，将解压步骤的文件夹路径粘贴并回车。将弹出窗口依次点击确认后关闭。不能点击右上角关闭按钮，如此修改将不会生效。

== 创建论文目录

从模板开源地址 #link("https://github.com/MoFChen/nenust")[github.com/MoFChen/nenust] 下载模板，下载完成后解压到合适的位置。熟悉 Git 的用户也可运行 `git clone https://github.com/MoFChen/nenust`。与 Git 结合使用能更方便地管理论文版本，具体使用方法这里不再展开。

使用 VSCode 打开模板文件夹。

`examples/empty` 是空白起点。复制 `empty` 文件夹并将副本改成合适的名字（这里演示改为 `my-thesis`）。副本中的 `main.typ`、`settings.typ` 和 `references.bib` 分别负责装配论文、保存配置与论文信息、保存参考文献，不需要重命名入口文件。

点击菜单栏的 Terminal 并再次点击 New Terminal 新建终端，或按下 #raw("Ctrl+Shift+`") 快捷键。

在终端页面输入 `typst --version` 检查环境变量是否设置正确以及 Typst 版本，若不能正常输出版本号请回到#ref(<sec-typst-cli-path>)检查步骤是否出错。

随后从仓库根目录运行完整编译命令。`--root .` 负责解析模板中的根路径，不能省略：

```powershell
typst compile --root . --font-path template/assets/fonts examples/my-thesis/main.typ
```

首次冷缓存编译需要联网下载模板使用的 `@preview/cuti:0.4.0` 包；文献模块是仓库内的纯 Typst 实现，不需要下载社区文献包。

使用 SumatraPDF 查看编译完成的 main.pdf 文件。空白项目仍会生成外封面、中英文信息页、委员会页、声明页、摘要、目录、正文标题和博士评语页；能够看到这些页面且终端没有编译错误，说明基础环境可用。

== 修改并再次编译

打开 `settings.typ`，尝试做以下修改：

· 将 `include_outer_cover` 的值修改为 `false`，关闭 A3 外封面输出；

· 修改 `information.title` 中的论文中英文标题。

再次运行上述 `typst compile` 命令编译 PDF，确认外封面和标题随配置变化。这就是后续写作的基本循环。

== 自动编译与预览

=== 自动编译

每次修改都要伴随执行编译命令实在是繁琐，Typst 提供了 watch 命令实时监控文件变化并自动进行增量编译，增量编译速度极快几乎等同于实时预览。

```powershell
typst watch --root . --font-path template/assets/fonts examples/my-thesis/main.typ
```

=== 预览

为了便于预览，PDF 查看工具应该支持两项功能（特性）：

· 自动刷新，文件发生更改自动重新载入文件，避免预览旧文件与代码产生出入；

· 自动刷新时不会从头开始预览，部分工具在自动刷新时会自动跳转到首页，这是不方便的；

在本章的演示中，使用了 SumatraPDF。这是一款开源、轻量的 PDF 阅读器，支持以上提到的两项特性。

预览工具不会影响最终编译结果。
