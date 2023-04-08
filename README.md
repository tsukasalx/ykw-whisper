# ykw-whisper

为音视频文件创建AI识别字幕。

一个whisper docker构建工具，隐藏构建过程，只使用简单命令执行对音视频的识别。

为女声优烤肉人修改了部分默认项：
* 语言：Japanese
* 模型：large
* 输出格式：ass

# 运行条件

1. win10 或 win11
2. 安装了nvidia显卡

# 依赖

知道含义的可以自行跳过或替换

## 1. 系统版本

win10用户（win11用户可跳过）：

查看系统版本，低于版本 2004 需要二选一
1. 升级成win11

或

2. 加入[Windows Insider Program](https://insider.windows.com/zh-cn/getting-started)
   * 注册微软账号
   * 选择“开始”按钮 > 选择“设置” > “更新& Windows 预览体验成员计划>安全性”。
   * 点击“入门”
   * 链接自己的微软账号
   * 在版本选择里选择最后一项
   * 从“设置”进入windows update页面，点击检查更新，等待更新完成后重启系统

## 2. WSL2

[安装并启用WSL2](https://learn.microsoft.com/zh-cn/windows/wsl/install)

## 3. Ubuntu

选择“开始”按钮，搜索并打开microsoft store（打不开商店请尝试关闭梯子）

搜索“ubuntu”，安装下记软件

![image](https://user-images.githubusercontent.com/5547526/230642591-58aea0ad-390c-466f-9a96-7d02d0c3dae0.png)

选择“开始”菜单，搜索“Linux”，运行Linux

![image](https://user-images.githubusercontent.com/5547526/230646379-7b146ae8-bf11-4e10-9569-68d6d7c934de.png)

依提示输入新用户名，新密码，完成初始化

## 4. Windows Terminal

选择“开始”按钮，搜索并打开microsoft store（打不开商店请尝试关闭梯子）

搜索“windows terminal”，安装下记软件

<img width="376" alt="image" src="https://user-images.githubusercontent.com/5547526/230644361-b7504417-955d-4d92-8a44-5fd07f96de75.png">

打开Windows Terminal，打开“设置”

![image](https://user-images.githubusercontent.com/5547526/230645453-072092c4-5bfa-43a7-a267-107e07b6b2f1.png)

将第一个默认配置选择为Ubuntu

![image](https://user-images.githubusercontent.com/5547526/230645622-7d7002d7-885b-4599-b775-f18d3b843ae8.png)

将Ubuntu启动目录设置为"."

![image](https://user-images.githubusercontent.com/5547526/230650555-ad849f4a-e8ca-4681-8626-9c97287cb6c1.png)

保存并退出

## 5. Docker Desktop

[下载安装Docker Desktop](https://www.docker.com/)，并运行

在主界面右上角点击设置![image](https://user-images.githubusercontent.com/5547526/230647767-1717285e-e20b-401c-b70a-7703f66047f7.png)

确保以下选项已启用

![image](https://user-images.githubusercontent.com/5547526/230648136-c0fd9fc8-faf5-4567-be20-d9419e68fad7.png)

以下列出的所有选项都选上，不要客气

![image](https://user-images.githubusercontent.com/5547526/230648588-fb082553-b477-4806-b1b2-923ff9b01cca.png)

右下角点击保存并重启

## 6. TortoiseGit

[下载并用默认选项安装TortoiseGit](https://tortoisegit.org/)

## 7. Nvidia最新显卡驱动

[下载安装最新驱动](https://www.nvidia.com/download/index.aspx)

# 准备工作

1. 复制该仓库的地址

![image](https://user-images.githubusercontent.com/5547526/230649222-2016d495-a8fb-4592-9fc2-e06afc0b499a.png)

2. 在windows文件浏览器保存位置右键打开菜单，找到Git Clone...

<img width="201" alt="image" src="https://user-images.githubusercontent.com/5547526/230649471-71ff7b7d-2315-480d-a11b-e2a30b203202.png">

3. 在新窗口中填入URL，确保选中Recursive选项，点击OK

![image](https://user-images.githubusercontent.com/5547526/230649915-39f93f0e-d3f6-49b7-9acf-4a067c1d0769.png)

4. 进入项目里的src目录，在目录里右键启动一个Terminal，然后运行 ./add_whisper_alias.sh，随即关闭该终端。

# 使用

1.打开音视频文件所在目录，右键选择用Terminal(终端)打开

2 执行命令行，即可生成同名ass字幕

`ykw-whisper file.mp4`

`ykw-whisper file.mp4 file2.mp3`

# 参数选项

-h：可查看并使用whisper的所有选项

--model：默认值为 large，指定不同的模型大小会占用不同的内存或显存，取决于使用cpu还是gpu，运行前需确保有足够的可用空间

|  Size  | Parameters | English-only model | Multilingual model | Required VRAM | Relative speed |
|:------:|:----------:|:------------------:|:------------------:|:-------------:|:--------------:|
|  tiny  |    39 M    |     `tiny.en`      |       `tiny`       |     ~1 GB     |      ~32x      |
|  base  |    74 M    |     `base.en`      |       `base`       |     ~1 GB     |      ~16x      |
| small  |   244 M    |     `small.en`     |      `small`       |     ~2 GB     |      ~6x       |
| medium |   769 M    |    `medium.en`     |      `medium`      |     ~5 GB     |      ~2x       |
| large  |   1550 M   |        N/A         |      `large`       |    ~10 GB     |       1x       |

--device：默认为gpu，也可使用cpu
