# OpenWrt for XG-040G-MD 🏠

> ⚠️ **个人配置，仅供参考** — 本仓库的配置是根据个人需求定制的，**不一定适用于所有人**。如需使用，请根据自身环境和需求自行调整 `.config` 文件。

基于 [xiangtailiang/openwrt](https://github.com/xiangtailiang/openwrt) 编译，适配 **NOKIA BELL XG-040G-MD (Airoha AN7581, aarch64)**

| 架构 | 包管理器 | 内核 |
|:---|:--------|:----|
| aarch64 | APK | Linux 6.12 |

- 已适配 SkyHigh 闪存，运行稳定（采用官方 Robust Read Workaround 补丁）
- Image 基于 OpenWrt **25.12** / **main** (snapshot) 分支构建
- 自动每 14 天检查上游更新并重新编译（[Full](./.github/workflows/14day-full-sync.yml) / [Slim](./.github/workflows/14day-slim-sync.yml)）
- Release 页面固件按版本前缀保留最新 3 个

---

## 📦 配置变体

本仓库维护两套配置，适应不同场景：

| 配置 | 定位 | 固件大小 | 适用场景 |
|:----|:-----|:--------|:--------|
| 🅰️ **Full** `xg-040g-md.config` | 功能齐全，全家桶 | 较大 | 跑满功能，什么都要 |
| 🅱️ **Slim** `xg-040g-md-slim.config` | 轻量够用，省资源 | 较小 | 稳定上网 + 基础管理 |

---

### 🅰️ Full 版 — 全插件全家桶

**科学上网**
- **HomeProxy** + **OpenClash** 双代理，灵活切换
- `sing-box` + `xray-core` 双引擎，兼容各类协议

**网络功能**
- 多线负载均衡 `mwan3`（含中文管理页）
- IGMP 代理 `igmp-proxy`（IPTV 组播）
- UPnP、WOL 网络唤醒

**文件 & 终端**
- **FileBrowser** — 网页文件管理
- **TTYD** — 网页终端
- **QuickFile** — 插 U 盘即用

**系统监控**
- CPU 温度监控 `cpustat`（含中文）
- 网络流量统计 `vnstat`（含中文）
- 网络诊断 `netmon`（含中文）
- 访问控制、系统日志、定时任务

---

### 🅱️ Slim 版 — 轻量精简便携

**科学上网**
- **OpenClash** — 唯一代理，配置简洁

**网络功能**
- `miniupnpd` — 轻量 UPnP（比 full 版更省资源）
- DDNS-GO 动态域名、WOL 网络唤醒

**文件管理**
- **QuickFile** — 内嵌 Luci，插 U 盘即用，中文界面

**系统工具**
- 定时任务 `cron`、系统日志、网页终端（QuickFile 内置）

**🔐 HTTPS 证书**
- **ACME** — Let's Encrypt 证书自动申请（LuCI 界面中文）
- ⚠️ 官方源版本较旧（2.8.5），建议刷机后手动升级 acme.sh 到最新版：
  ```bash
  wget https://github.com/acmesh-official/acme.sh/archive/master.tar.gz
  tar xzf master.tar.gz && cd acme.sh-master
  ./acme.sh --install --home /usr/lib/acme --cert-home /etc/acme/certs --config-home /etc/acme/config
  chmod 755 /usr/lib/acme/acme.sh
  ```

**已精简掉的插件**
| 移除项 | 原因 |
|--------|------|
| HomeProxy / sing-box | 只留 OpenClash，减少代理引擎冗余 |
| xray-core | OpenClash 自带，无需额外安装 |
| mwan3 | 单线场景用不上多线负载 |
| FileBrowser | QuickFile 已覆盖文件管理需求 |
| TTYD | QuickFile 内置网页终端 |
| igmp-proxy / luci-app-iptv | 不需要 IPTV 组播 |
| cpustat / vnstat / netmon | 追求最小固件体积，监控可选装 |
| accesscontrol | 家长控制，个人用不上 |

> Slim 版适合：**J4125 / 低功耗平台**，主要需求科学上网 + 插 U 盘看文件，追求最小固件体积和稳定性。

---

## 🔄 自动更新机制

| 工作流 | 触发 | 行为 |
|--------|------|------|
| [Full 版同步](.github/workflows/14day-full-sync.yml) | 每 14 天 08:00 + 手动 | 检查上游更新 → 有更新则触发 Full 编译 |
| [Slim 版同步](.github/workflows/14day-slim-sync.yml) | 每 14 天 08:00 + 手动 | 检查上游更新 → 有更新则触发 Slim 编译 |
| [Main 编译](.github/workflows/xg-040g-md-openwrt-main.yml) | Push / dispatch | 编译 Full main 分支固件并发布 Release |
| [25.12 编译](.github/workflows/xg-040g-md-openwrt-25.12.yml) | Push / dispatch | 编译 Full 25.12 分支固件并发布 Release |
| [Main Slim 编译](.github/workflows/xg-040g-md-openwrt-main-slim.yml) | Push / dispatch | 编译 Slim main 分支固件并发布 Release |
| [25.12 Slim 编译](.github/workflows/xg-040g-md-openwrt-25.12-slim.yml) | Push / dispatch | 编译 Slim 25.12 分支固件并发布 Release |

所有 workflow 使用独立的 concurrency 组，确保并行编译不互相干扰。

---

## 🔧 刷机

1. **刷入 U-Boot**: [参考通用的 XG-040G-MD 刷机教程](https://nwrt.kuroneko.host/flashdocs/XG-040G-MD.html)
2. **刷入系统**: 在 U-Boot Web 恢复界面中，上传并刷入本仓库 Release 页面发布的 **factory** 固件。

> [!WARNING]
> **进入 U-Boot 的正确方法：**
> 给路由器通电等 **3秒钟** 后，再按住 reset 键不放。
> **千万不要**按住 reset 键再通电，否则机器会进入底层的"救砖模式"（MaskROM/Emergency 模式），将无法进入 U-Boot Web 界面。

---

## 📁 Docs

- [`docs/npu-firmware-load.md`](docs/npu-firmware-load.md): NPU 固件加载报错（`-2`）分析与修复记录