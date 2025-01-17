#!/bin/bash

# 定义颜色
RED="\033[31m"
GREEN="\033[32m"
NC="\033[0m"

# 检查是否为 root 用户
if [ $EUID -ne 0 ]; then
    echo -e "${RED}请使用 root 用户运行此脚本${NC}"
    exit 1
fi

echo -e "${GREEN}开始卸载 frps...${NC}"

# 停止并禁用服务
systemctl stop frps
systemctl disable frps

# 获取当前用户的 home 目录
USER_HOME=$(eval echo ~${SUDO_USER})

# 删除文件
rm -rf ${USER_HOME}/frp
rm -f /etc/systemd/system/frps.service

# 重载 systemd
systemctl daemon-reload

echo -e "${GREEN}frps 已成功卸载！${NC}"