#!/bin/bash

#curl https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi.sh | bash
#wget -O luodi.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi.sh && sudo bash luodi.sh
#一键安装落地机翻墙服务
#搭配中转机使用

#确认要安装
#read -r -p "运行此脚本会卸载v2ray等服务，之前的节点也将不可用，是否继续安装? [Y/n] " input
#case $input in
#    [yY][eE][sS]|[yY])
#		echo "开始安装"
#		;;
#
#    [nN][oO]|[nN])
#		echo "退出安装"
#  		exit 1
#       	;;
#
#    *)
#		echo "Invalid input..."
#		exit 1
#		;;
#esac

#函数---显示安装结束后的配置信息
function print_result_info() {
	
	if [[ "vmess" = "$1" || "vless" = "$1" ]]; then		
		echo "协议: "$1
		echo "端口: 9800"
		echo "用户id: af41686b-cb85-494a-a554-eeaa1514bca7"
		echo "加密方式: none"
		echo "传输协议: ws"
		echo "路径: /ab596b5a5d3636b5-002"
	fi

	if [ "ss" = "$1" ]; then		
		echo "协议: "$1
		echo "端口: 9800"
		echo "密码: a25b63c555a5987d6"
		echo "加密方式: chacha20-ietf-poly1305"
		echo "传输协议: ws"
		echo "路径: /ab596b5a5d3636b5-002"
	fi

	echo -e "\n"
	if [ "vmess" = "$1" ]
	then
		echo "复制以下链接到VPN客户端，更改ip地址即可"
		echo "vmess://ew0KICAidiI6ICIyIiwNCiAgInBzIjogIuiQveWcsOacuiIsDQogICJhZGQiOiAiMS4yLjIuMiIsDQogICJwb3J0IjogIjk4MDAiLA0KICAiaWQiOiAiYWY0MTY4NmItY2I4NS00OTRhLWE1NTQtZWVhYTE1MTRiY2E3IiwNCiAgImFpZCI6ICIwIiwNCiAgInNjeSI6ICJub25lIiwNCiAgIm5ldCI6ICJ3cyIsDQogICJ0eXBlIjogIm5vbmUiLA0KICAiaG9zdCI6ICIiLA0KICAicGF0aCI6ICIvYWI1OTZiNWE1ZDM2MzZiNS0wMDIiLA0KICAidGxzIjogIiIsDQogICJzbmkiOiAiIiwNCiAgImFscG4iOiAiIg0KfQ=="
	elif [ "vless" = "$1" ]
	then
		echo "复制以下链接到VPN客户端，更改ip地址"
		echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@1.2.2.2:9800?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b5-002#%E8%90%BD%E5%9C%B0%E6%9C%BA"
	elif [ "ss" = "$1" ]
	then
		echo "复制以下链接到VPN客户端，更改ip地址，选择ws，更改路径(ss链接无法包含以上信息,只能手动添加)"
		echo "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTphMjViNjNjNTU1YTU5ODdkNg==@1.2.2.2:9800#%E8%90%BD%E5%9C%B0%E6%9C%BA"
	elif [ "trojan" = "$1" ]
	then
		echo "不支持trajan(必带tls)"
	else
		echo "未安装v2ray等服务，请先安装！"
	fi	
	
	echo -e "\n\n"
}


#函数---判断当前是用什么协议,并打印配置信息
function check_what_protocol_and_print() {
	pro=$(cat /usr/local/etc/v2ray/config.json)
	if [[ $pro =~ "vmess" ]];then
	    print_result_info "vmess"
	elif [[ $pro =~ "vless" ]];then
		print_result_info "vless"
	elif [[ $pro =~ "shadowsocks" ]];then
		print_result_info "ss"
	elif [[ $pro =~ "trojan" ]];then
		print_result_info "trojan"
	else
	    print_result_info "uninstall"
	fi
}



#脚本功能选择
while true
do
echo -e "\n选择以下脚本功能---"
echo "1) 安装"
echo "2) 查看节点配置"
echo "3) 重启服务"
echo "4) 查看v2ray运行状态"
echo "5) 查看v2ray配置文件"
echo "6) 查看nginx运行状态"
echo "7) 查看nginx配置文件"
read -r -p "请输入数字选择: " input
case $input in
    1) 
    		echo "开始安装"
    		break
    		;;
    2) 
    		echo -e "\n\n\n\n\n\n\n\n\n\n\n\n"
    		check_what_protocol_and_print
    		continue
    		;;
    3) 
    		systemctl restart v2ray
    		systemctl restart nginx
    		echo "服务已重启"
    		continue
    		;;    		
    4) 
    		systemctl status v2ray
    		continue
    		;;
    5) 
    		cat /usr/local/etc/v2ray/config.json
    		continue
    		;;
    6) 
    		systemctl status nginx
    		continue
    		;;
    7) 
    		cat /etc/nginx/nginx.conf
    		continue
    		;;    		
    *) 
    		echo "invalid option...退出脚本"
    		exit 1
    		;;
esac
done


#默认协议vmess
protocol_choice="vmess"

echo -e "\n\n需要安装以下哪种协议?"
echo "1) vmess"
echo "2) vless"
echo "3) ss"
#echo "4) trojan"
read -r -p "请输入数字选择: " input
case $input in
    1) 
    		echo "选定安装vmess协议"
    		protocol_choice="vmess"
    		;;
    2) 
    		echo "选定安装vless协议"
    		protocol_choice="vless"
    		;;
    3) 
    		echo "选定安装ss协议"
    		protocol_choice="ss"
    		;;
#    4) 
#    		echo "选定安装trojan协议"
#    		protocol_choice="trojan"
#    		;;
    *) 
    		echo "invalid option...退出安装"
    		exit 1
    		;;
esac

echo "安装依赖包"
apt update -y && apt install -y netcat && apt install -y net-tools && apt install -y curl && apt install -y socat && apt install -y wget && apt install -y unzip && apt install -y ufw

#防火墙设置
echo "设置ufw"
ufw allow ssh
ufw allow 9800
ufw allow 80
ufw disable

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
rm jiedian.json
if [ "vless" = $protocol_choice ]
then
	echo "下载vless配置文件"
	wget -O jiedian.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/vless.json
elif [ "ss" = $protocol_choice ]
then
	echo "下载ss配置文件"
	wget -O jiedian.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/ss.json
elif [ "trojan" = $protocol_choice ]
then
	echo "下载trojan配置文件"
	wget -O jiedian.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/trojan.json
else
	echo "下载vmess配置文件"
	wget -O jiedian.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/vmess.json
fi	
rm /usr/local/etc/v2ray/config.json
cp jiedian.json /usr/local/etc/v2ray/config.json

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

print_result_info $protocol_choice
