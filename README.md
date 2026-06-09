# OpenWrt for XG-040G-MD

OpenWrt firmware for **NOKIA BELL XG-040G-MD (Airoha AN7581, aarch64)**

- 源仓库：[https://github.com/xiangtailiang/openwrt](https://github.com/xiangtailiang/openwrt)
- 架构：**aarch64** | 包管理器：**APK** | 内核：**Linux 6.12**
- 已适配 SkyHigh 闪存，运行稳定（采用官方 Robust Read Workaround 补丁）
- Image 基于 OpenWrt 25.12 / main (snapshot) 分支构建

## 包含的插件 (LuCI Apps)

### 科学上网
- [HomeProxy](https://github.com/immortalwrt/homeproxy)
- [OpenClash](https://github.com/vernesong/OpenClash)

### 基础网络
- 防火墙 (nftables + firewall4)
- dnsmasq-full (DHCP/DNS/IPv6)
- 多线负载均衡 (mwan3)
- UPnP (通用即插即用)
- WOL (网络唤醒)
- IGMP 组播代理 (IPTV 必备)

### 文件与存储
- FileBrowser（文件浏览器）
- TTYD（网页终端）
- filetransfer（文件上传下载）
- exFAT / FAT32 / ext4 文件系统支持
- USB 存储支持 (USB 2.0/3.0)

### 系统管理
- LuCI (支持 HTTPS)
- Argon 主题 + 配置页
- 中文语言包
- CPU / 温度监控 (cpustat)
- 系统日志
- Netmon（网络诊断）
- 带宽监控 (nlbwmon)
- 定时任务 (cron)
- IPTV 管理

### 其他工具
- DDNS-GO（动态域名解析）
- curl / wget-ssl
- tcpdump（网络抓包）
- ethtool（网卡诊断）

## 刷机教程

1. **刷入 U-Boot**: [点击参考通用的 XG-040G-MD 刷机教程](https://nwrt.kuroneko.host/flashdocs/XG-040G-MD.html)
2. **刷入系统**: 在 U-Boot Web 恢复界面中，上传并刷入本仓库 Release 页面发布的 **factory** 固件。

> [!WARNING]
> **进入 U-Boot 的正确方法：**
> 给路由器通电等 **3秒钟** 后，再按住 reset 键不放。
> **千万不要**按住 reset 键再通电，否则机器会进入底层的"救砖模式"（MaskROM/Emergency 模式），将无法进入 U-Boot Web 界面。

## Docs

- `docs/npu-firmware-load.md`: NPU 固件加载报错（`-2`）分析与修复记录
