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
if [ -f "/home/frp/frps" ]; then
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

# 生成随机 token (32位随机字符)
RANDOM_TOKEN=$(openssl rand -hex 16)

# 获取当前用户的 home 目录
if [ -n "${SUDO_USER}" ]; then
    USER_HOME=$(eval echo ~${SUDO_USER})
    REAL_USER=${SUDO_USER}
else
    USER_HOME=$HOME
    REAL_USER=$(whoami)
fi

echo -e "${GREEN}安装目录: ${USER_HOME}/frp${NC}"

# 创建目录并复制文件
mkdir -p ${USER_HOME}/frp
cp frp_${VERSION:1}_linux_${ARCH}/frps ${USER_HOME}/frp/
# 创建 TOML 配置文件
cat > ${USER_HOME}/frp/frps.toml << EOF
# frps 配置文件

# 基础配置
bindPort = 7000
bindAddr = "0.0.0.0"

# 面板配置
webServer.port = 7500
webServer.addr = "0.0.0.0"
webServer.user = "admin"
webServer.password = "$(openssl rand -hex 8)"

# 认证配置
auth.token = "${RANDOM_TOKEN}"

# 日志配置
log.to = "console"
log.level = "info"
log.maxDays = 3

# 端口配置
allowPorts = [
    { start = 10000, end = 20000 }
]
EOF

# 修改 systemd 服务文件中的配置文件路径
cat > /etc/systemd/system/frps.service << EOF
[Unit]
Description=frps service
After=network.target

[Service]
Type=simple
ExecStart=${USER_HOME}/frp/frps -c ${USER_HOME}/frp/frps.toml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 设置权限
chmod +x ${USER_HOME}/frp/frps
if [ "${REAL_USER}" != "root" ]; then
    chown -R ${REAL_USER}:${REAL_USER} ${USER_HOME}/frp
fi

# 启动服务
systemctl daemon-reload
systemctl enable frps
systemctl start frps

# 删除解压后的文件
rm -rf frp_${VERSION:1}_linux_${ARCH}

echo -e "${GREEN}frps $VERSION 安装完成！${NC}"
echo -e "${GREEN}服务已启动并设置为开机自启${NC}"
echo -e "${YELLOW}请查看配置文件 ${USER_HOME}/frp/frps.toml 获取随机生成的token和面板密码${NC}"
echo -e "${YELLOW}token: ${RANDOM_TOKEN}${NC}"

# 检查服务状态
sleep 1
if ! systemctl is-active --quiet frps; then
    echo -e "${RED}服务启动失败，请检查日志：${NC}"
    journalctl -u frps --no-pager -n 10
fi