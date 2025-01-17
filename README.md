# FRP Server 一键安装脚本

这是一个用于在 Debian/Ubuntu 服务器上快速部署 frp 服务端（frps）的一键安装/卸载脚本。

## 功能特点

- ✨ 自动获取并安装最新版本 frp
- 🖥️ 支持多种系统架构 (amd64/arm64/arm)
- 🚀 自动安装并配置 systemd 服务
- 🔄 支持开机自启动
- 🛡️ 基础安全配置
- 🗑️ 完整的卸载功能
- 💻 友好的命令行提示

## 快速开始

### 安装

```bash
# 下载安装脚本
wget -O install_frps.sh https://raw.githubusercontent.com/your-repo/install_frps.sh
wget -O uninstall_frps.sh https://raw.githubusercontent.com/your-repo/uninstall_frps.sh

# 添加执行权限
chmod +x install_frps.sh uninstall_frps.sh

# 执行安装
sudo ./install_frps.sh
```

### 卸载

```bash
# 执行卸载
sudo ./uninstall_frps.sh
```

## 使用说明

### 配置文件

安装完成后，配置文件位于：`/usr/local/frp/frps.ini`

默认配置示例：
```ini
[common]
bind_port = 7000
token = 12345678
```

**重要：** 请务必修改默认配置，特别是 `token` 以确保安全性。

### 服务管理

```bash
# 启动服务
sudo systemctl start frps

# 停止服务
sudo systemctl stop frps

# 重启服务
sudo systemctl restart frps

# 查看服务状态
sudo systemctl status frps

# 查看服务日志
sudo journalctl -u frps
```

### 防火墙设置

如果您的服务器开启了防火墙，需要开放相应端口：

```bash
# UFW防火墙
sudo ufw allow 7000

# 重载防火墙
sudo ufw reload
```

## 目录结构

安装后的文件结构：
```
/usr/local/frp/
├── frps           # 主程序
└── frps.ini       # 配置文件

/etc/systemd/system/
└── frps.service   # 服务文件
```

## 常见问题

1. **安装失败**
   - 检查是否有足够的权限（需要 root 权限）
   - 检查网络连接是否正常
   - 查看详细日志：`journalctl -u frps`

2. **服务无法启动**
   - 检查配置文件格式是否正确
   - 检查端口是否被占用
   - 查看详细日志：`journalctl -u frps`

3. **客户端无法连接**
   - 检查防火墙设置
   - 确认 `token` 配置是否正确
   - 验证服务器端口是否开放

## 更新日志

- 2024-02-25: 
  - 支持自动获取并安装最新版本
  - 增加多架构支持 (amd64/arm64/arm)
  - 优化安装流程
  - 使用 .ini 配置文件格式

## 注意事项

1. 本脚本仅在 Debian/Ubuntu 系统上测试过
2. 安装前请确保系统已安装基本工具（wget、tar）
3. 建议在安装完成后立即修改默认配置
4. 请定期关注 frp 官方更新，及时更新到最新版本

## 相关链接

- [FRP 官方项目](https://github.com/fatedier/frp)
- [FRP 官方文档](https://gofrp.org/docs/)

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 致谢

- [fatedier/frp](https://github.com/fatedier/frp) - 原版 frp 项目