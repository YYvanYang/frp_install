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
wget -O install_frps.sh https://raw.githubusercontent.com/YYvanYang/frp_install/main/install_frps.sh
wget -O uninstall_frps.sh https://raw.githubusercontent.com/YYvanYang/frp_install/main/uninstall_frps.sh

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

安装完成后，配置文件位于：`~/frp/frps.toml`

默认配置示例：
```toml
# frps 配置文件

# 基础配置
bindPort = 7000
bindAddr = "0.0.0.0"

# 面板配置
webServer.port = 7500
webServer.addr = "0.0.0.0"
auth.method = "token"
auth.token = "8c7dd910c1ad6b588f46a7e9e6316f4a"  # 安装时随机生成
webServer.user = "admin"
webServer.password = "af7c1fe428c9d688"  # 安装时随机生成

# 连接池配置
maxPoolCount = 5

# 性能优化
transport.tcpMux = true

# 日志配置
log.to = "console"
log.level = "info"
log.maxDays = 3

# 端口白名单，用逗号分隔
allowPorts = [
    { start = 10000, end = 20000 }
]
```

**重要：** 
- 安装脚本会自动生成随机的 token 和面板密码
- token 和密码会在安装完成时显示，请务必保存
- 如需修改，可以直接编辑配置文件
- 修改配置后需要重启服务：`sudo systemctl restart frps`

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
# frp 服务端口
sudo ufw allow 7000
# 面板端口
sudo ufw allow 7500
# 客户端映射端口范围（根据实际配置调整）
sudo ufw allow 10000:20000/tcp

# 重载防火墙
sudo ufw reload
```

## 目录结构

安装后的文件结构：
```
~/frp/
├── frps           # 主程序
└── frps.toml      # 配置文件

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

4. **管理面板无法访问**
   - 确认 dashboard_port 端口是否开放
   - 检查防火墙设置
   - 确认 dashboard_user 和 dashboard_pwd 配置正确

5. **性能优化建议**
   - 启用 tcp_mux 可以复用连接，提高性能
   - 合理设置 max_pool_count 限制连接数
   - 根据实际需求配置 allow_ports 端口范围

## 更新日志

- 2024-02-25: 
  - 支持自动获取并安装最新版本
  - 增加多架构支持 (amd64/arm64/arm)
  - 优化安装流程
  - 使用 TOML 配置文件格式
  - 增加更多标准配置项

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