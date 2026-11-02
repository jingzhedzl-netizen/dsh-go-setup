# 电脑端：装 DSH

## 1. 装桌面端

去 [官网下载](https://www.deepseek.com/download/) 拿 Windows 安装包，双击装完打开。

第一次打开会让你选模型渠道。两种都行：

- DeepSeek 账号登录：点「用 DeepSeek 账号登录」，浏览器里授权，回来就能用。
- API Key：在设置里填 Key，按量计费。

装完先随便问一句，确认能出字。出不了字先解决模型，不要往下走。

## 2. 装 Remote 插件

这一步让手机能连过来。

1. 打开 DSH，进「扩展」或「插件管理」。
2. 选「从 npm 安装」。
3. 输入 `ds-harness-remote@0.6.0`，确认。
4. 装完重启 DSH。

命令行也行：

```powershell
dsh plugin --profile desktop add -w ds-harness-remote@0.6.0
```

如果 `dsh` 不在 PATH，用桌面版自带的那份：

```powershell
& "D:\DeepSeekharness\resources\runtime\cli\bin\dsh.cmd" plugin --profile desktop add -w ds-harness-remote@0.6.0
```

路径按你自己的安装位置改。

## 3. 登录 Remote

重启后，左侧栏会多一个 Remote。点进去：

1. 用账号登录。GitHub 或邮箱都行，记住你用的哪种，手机要选一样的。
2. 确认「允许这台设备被控制」是开着的。
3. 页面显示「在线」或一个设备 ID，就够了。

## 4. 检查

```powershell
.\scripts\check-windows.ps1
```

会列出 DSH 装没装、Remote 插件在不在、端口和进程状态。只读，不改东西。

## 常见卡点

| 现象 | 怎么办 |
|---|---|
| 插件管理里搜不到 | 确认网络能访问 npm；换命令行装 |
| 装完侧栏没有 Remote | 没重启，或者装到了别的 profile |
| 登录后一直转圈 | 换网络；看电脑能不能打开 `https://dsh.r2049.cn` |
| 提示版本不匹配 | 插件不是 0.6.0，或者 DSH 太旧 |
