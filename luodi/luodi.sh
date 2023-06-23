#!/bin/bash

echo "下载v2ray安装脚本"
#bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove
rm v2ray-install-release.sh
wget -O v2ray-install-release.sh https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
chmod 777 v2ray-install-release.sh
echo "v2ray安装脚本下载完成"

echo "卸载v2ray"
./v2ray-install-release.sh --remove

echo "安装v2ray"
./v2ray-install-release.sh
