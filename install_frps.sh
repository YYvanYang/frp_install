#!/bin/bash

# 定义颜色
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
NC="\033[0m"

# 检查是否为 root 用户
if [ $EUID -ne 0 ]; then
    echo -e "${RED}请使用 root 用户运行此脚本${NC}"
    exit 1
fi

# 获取系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    armv7l)
        ARCH="arm"
        ;;
    *)
        echo -e "${RED}不支持的系统架构: $ARCH${NC}"
        exit 1
        ;;
esac

# 获取最新版本号
echo -e "${GREEN}正在获取最新版本...${NC}"
VERSION=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep -o '"tag_name": ".*"' | cut -d'"' -f4)
if [ -z "$VERSION" ]; then
    echo -e "${RED}获取版本信息失败${NC}"
    exit 1
fi

echo -e "${GREEN}最新版本为: $VERSION${NC}"

# 检查是否已安装
if [ -f "/usr/local/frp/frps" ]; then
    echo -e "${YELLOW}检测到已安装frps，正在卸载...${NC}"
    bash uninstall_frps.sh
fi

# 下载并解压
DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/${VERSION}/frp_${VERSION:1}_linux_${ARCH}.tar.gz"
echo -e "${GREEN}正在下载 frps...${NC}"
wget -q $DOWNLOAD_URL -O frp.tar.gz || {
    echo -e "${RED}下载失败${NC}"
    exit 1
}

echo -e "${GREEN}正在解压...${NC}"
tar -xf frp.tar.gz
rm frp.tar.gz

# 创建目录并复制文件
mkdir -p /usr/local/frp
cp frp_${VERSION:1}_linux_${ARCH}/frps /usr/local/frp/
cp frp_${VERSION:1}_linux_${ARCH}/frps.ini /usr/local/frp/
rm -rf frp_${VERSION:1}_linux_${ARCH}

# 创建 systemd 服务
cat > /etc/systemd/system/frps.service << EOF
[Unit]
Description=frps service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.ini
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 设置权限
chmod +x /usr/local/frp/frps

# 启动服务
systemctl daemon-reload
systemctl enable frps
systemctl start frps

echo -e "${GREEN}frps $VERSION 安装完成！${NC}"
echo -e "${GREEN}服务已启动并设置为开机自启${NC}"
echo -e "${YELLOW}请修改配置文件 /usr/local/frp/frps.ini 后重启服务${NC}"