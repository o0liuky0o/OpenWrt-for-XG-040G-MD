# OpenWrt for XG-040G-MD

OpenWrt firmware for **NOKIA BELL XG-040G-MD (Airoha AN7581, aarch64)**

- 源仓库：[https://github.com/xiangtailiang/openwrt](https://github.com/xiangtailiang/openwrt)
- 架构：**aarch64** | 包管理器：**APK** | 内核：**Linux 6.12**
- 已适配 SkyHigh 闪存，运行稳定（采用官方 Robust Read Workaround 补丁）
- Image 基于 OpenWrt **25.12** / **main** (snapshot) 分支构建

## 配置变体

本仓库提供两种 `.config` 配置，适应不同需求：

| 配置 | 特点 | 适用场景 |
|:----|:----|:--------|
| 🅰️ `xg-040g-md.config` | **全插件版** — 功能齐全 | 需要多种代理和监控工具 |
| 🅱️ `xg-040g-md-slim.config` | **精简便携版** — 轻量省资源 | 只求稳定上网 + 基本管理 |

---

### 🅰️ 全插件版 (`xg-040g-md.config`)

| 分类 | 包含 |
|:----|:----|
| 🌐 科学上网 | HomeProxy, OpenClash, xray-core |
| 📡 网络 | 防火墙 (nftables), dnsmasq, mwan3(负载均衡), UPnP, WOL, IGMP(IPTV) |
| 📁 文件 | FileBrowser, TTYD, filetransfer |
| 🖥 系统 | CPU监控, 带宽监控, 系统日志, Netmon, 定时任务, IPTV管理 |
| 🔧 工具 | DDNS-GO, tcpdump, ethtool, curl |

### 🅱️ 精简便携版 (`xg-040g-md-slim.config`)

| 分类 | 包含 |
|:----|:----|
| 🌐 科学上网 | **HomeProxy**（唯一代理，轻量 Rust 核心）|
| 📡 网络 | 防火墙 (nftables), dnsmasq, UPnP(miniupnpd), WOL, DDNS-GO |
| 📁 文件 | **QuickFile**（内嵌 Luci，插 U 盘即用，中文界面）|
| 🖥 系统 | 定时任务, 系统日志, 网页终端(QuickFile内置) |
| 🔧 工具 | tcpdump, cron, curl |
| ❌ 已精简 | OpenClash / xray-core / mwan3 / FileBrowser / TTYD / CPU监控 / 带宽监控 |

**精简便携版适合：** J4125 这种低功耗平台，主要需求是科学上网 + 插 U 盘看文件，追求最小固件体积。

---

## 刷机教程

1. **刷入 U-Boot**: [点击参考通用的 XG-040G-MD 刷机教程](https://nwrt.kuroneko.host/flashdocs/XG-040G-MD.html)
2. **刷入系统**: 在 U-Boot Web 恢复界面中，上传并刷入本仓库 Release 页面发布的 **factory** 固件。

> [!WARNING]
> **进入 U-Boot 的正确方法：**
> 给路由器通电等 **3秒钟** 后，再按住 reset 键不放。
> **千万不要**按住 reset 键再通电，否则机器会进入底层的"救砖模式"（MaskROM/Emergency 模式），将无法进入 U-Boot Web 界面。

## Docs

- `docs/npu-firmware-load.md`: NPU 固件加载报错（`-2`）分析与修复记录
