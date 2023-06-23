#!/bin/bash

#curl https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi.sh | bash
#wget -O luodi.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi.sh && sudo bash luodi.sh
#一键安装落地机翻墙服务
#搭配中转机使用

echo "下载v2ray安装脚本"
rm v2ray-install-release.sh
wget -O v2ray-install-release.sh https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
chmod 777 v2ray-install-release.sh
echo "v2ray安装脚本下载完成"

echo "卸载v2ray"
systemctl disable v2ray
systemctl stop v2ray
./v2ray-install-release.sh --remove

echo "安装v2ray"
./v2ray-install-release.sh

echo "下载v2ray.service文件"
wget -O v2ray.service https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/v2ray.service
rm /etc/systemd/system/v2ray.service
cp v2ray.service /etc/systemd/system/v2ray.service
systemctl daemon-reload

echo "下载节点配置文件"
rm vmess.json
wget -O vmess.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/vmess.json
rm /usr/local/etc/v2ray/config.json
cp vmess.json /usr/local/etc/v2ray/config.json

echo "安装nginx"
apt install nginx

echo "下载nginx配置文件"
rm nginx.conf
wget -O nginx.conf https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/nginx/nginx.conf
rm /etc/nginx/nginx.conf
cp nginx.conf /etc/nginx/nginx.conf
chmod 777 /etc/nginx/nginx.conf

echo "重启v2ray nginx"
systemctl restart v2ray.service
systemctl restart nginx.service

echo -e "\n\n\n"
echo "安装完成！！！！！！！！"
echo "协议: vmess"
echo "端口: 9800"
echo "用户id: af41686b-cb85-494a-a554-eeaa1514bca7"
echo "加密方式: none"
echo "传输协议: ws"
echo "路径: /ab596b5a5d3636b5-002"
