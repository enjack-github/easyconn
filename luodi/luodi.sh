#!/bin/bash

#curl https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi.sh | bash
#一键安装落地机翻墙服务
#搭配中转机使用

echo "下载v2ray安装脚本"
#bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove
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
