#!/bin/bash

# 定义颜色
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
NC="\033[0m"

# 定义版本和架构
FRP_VERSION="0.61.1"
ARCH="amd64"

echo -e "${GREEN}开始安装 frps...${NC}"

# 检查是否为 root 用户
if [ $EUID -ne 0 ]; then
    echo -e "${RED}请使用 root 用户运行此脚本${NC}"
    exit 1
fi

# 创建安装目录
install_dir="/usr/local/frp"
mkdir -p $install_dir

# 下载并解压 frp
echo -e "${YELLOW}下载 frp ${FRP_VERSION}...${NC}"
wget -q https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${ARCH}.tar.gz -O /tmp/frp.tar.gz

if [ $? -ne 0 ]; then
    echo -e "${RED}下载失败！${NC}"
    exit 1
fi

tar -zxf /tmp/frp.tar.gz -C /tmp
cp /tmp/frp_${FRP_VERSION}_linux_${ARCH}/frps $install_dir/
rm -rf /tmp/frp.tar.gz /tmp/frp_${FRP_VERSION}_linux_${ARCH}

# 创建配置文件
cat > $install_dir/frps.toml << EOF
bindPort = 7000
# 请修改以下配置
auth.token = "12345678"
EOF

# 创建 systemd 服务文件
cat > /etc/systemd/system/frps.service << EOF
[Unit]
Description=frp server
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.toml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 设置权限
chmod +x $install_dir/frps
chmod 644 $install_dir/frps.toml
chmod 644 /etc/systemd/system/frps.service

# 重载 systemd 并启动服务
systemctl daemon-reload
systemctl enable frps
systemctl start frps

# 检查服务状态
if systemctl is-active --quiet frps; then
    echo -e "${GREEN}frps 安装成功！${NC}"
    echo -e "${YELLOW}请修改配置文件：${NC} /usr/local/frp/frps.toml"
    echo -e "${YELLOW}常用命令：${NC}"
    echo "systemctl start frps   # 启动服务"
    echo "systemctl stop frps    # 停止服务"
    echo "systemctl restart frps # 重启服务"
    echo "systemctl status frps  # 查看状态"
else
    echo -e "${RED}frps 安装失败，请检查日志：journalctl -u frps${NC}"
fi