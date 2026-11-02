# DSH + DSH Go 配置清单

给组里人用的安装笔记。照着做，电脑和手机能连起来，手机上也能接着用电脑上的 DSH。

- 电脑端：DeepSeek Harness，官方项目。
- 手机端：DSH Go，社区项目，不是官方。

## 先选路线

| 路线 | 适合谁 | 要装的东西 |
|---|---|---|
| A. DSH Remote | 大多数人，先走这条 | 电脑装 DSH + Remote 插件，手机装 DSH Go |
| B. SSH + Tailscale | 想自己控网络、能折腾 | 再加 OpenSSH、Tailscale，Windows 还要 WSL |

A 走通再考虑 B。B 在 Windows 上有坑，见 `docs/04-ssh-wsl.md`。

## 五分钟跑通 A

1. 电脑装 DSH 桌面端，登录或填 API Key。
2. 电脑打开插件管理，装 `ds-harness-remote@0.6.0`，重启 DSH。
3. 电脑侧栏点 Remote，登录，打开「允许控制这台设备」。
4. 手机装 DSH Go，打开，选「连接电脑或服务器」。
5. 手机用同一个账号登录，选中电脑，核对指纹，点信任。

细节在 `docs/01-pc-dsh.md`、`docs/02-phone-dshgo.md`、`docs/03-remote.md`。

## 下载

| 文件 | 在哪 |
|---|---|
| DSH Go 1.0.4 arm64 | 本仓库 Releases，或 [官方 Release](https://github.com/ccch1mneyyy/dsh-go/releases/tag/v1.0.4) |
| Tailscale 1.104.4 | [官方 Release](https://github.com/tailscale/tailscale-android/releases) |
| DSH 桌面端 | [官网下载](https://www.deepseek.com/download/) |
| Shizuku | [官方 Release](https://github.com/RikkaApps/Shizuku/releases) |

下载后先校验：

```powershell
.\scripts\verify-downloads.ps1 -Directory .\downloads
```

## 文档

| 文件 | 内容 |
|---|---|
| [docs/01-pc-dsh.md](docs/01-pc-dsh.md) | 电脑装 DSH、配模型、装 Remote 插件 |
| [docs/02-phone-dshgo.md](docs/02-phone-dshgo.md) | 手机装 DSH Go、权限、虚拟屏 |
| [docs/03-remote.md](docs/03-remote.md) | DSH Remote 配对、路径、限制 |
| [docs/04-ssh-wsl.md](docs/04-ssh-wsl.md) | SSH + Tailscale，Windows 的 WSL 方案 |
| [docs/05-troubleshooting.md](docs/05-troubleshooting.md) | 连不上、登录失败、启动失败 |
| [docs/06-faq.md](docs/06-faq.md) | 是不是官方、数据安全、iOS |

## 三个注意

1. DSH Go 是社区项目。没有企业级 SLA，更新和支持靠社区。
2. 不要把 API Key、密码、token 提交到仓库。这个仓库只放文档和脚本。
3. 手机操控只对手机本机引擎有效。连远程电脑时用不了。

## 维护

- 软件版本变了，改 `manifest/packages.json` 和对应文档。
- 新踩的坑，补到 `docs/05-troubleshooting.md`，写清楚「现象、原因、怎么做」。
