#!/bin/bash

echo "卸载v2ray"
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove
# wget -O v2ray-install-release.sh https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
