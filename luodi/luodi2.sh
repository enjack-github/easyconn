#!/bin/bash

#一键安装脚本
#wget -O luodi2.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi2.sh && sudo bash luodi2.sh
#安装两个vless，分别用9801 9802，其中一个节点当作备用线路
#搭配中转机使用

#函数---获取ip
function get_my_ip() {
	#爬取ipinfo.io获取信息
	full_ipinfo=$(curl ipinfo.io)
	
	#截取"ip":之前内容，要用转义字符
	my_ip=${full_ipinfo#*\"ip\":}
	
	#截取"之前内容，要用转义字符
	my_ip=${my_ip#*\"}
	
	#截取"之后的内容，要用转义字符，注意*号位置和之前不同
	my_ip=${my_ip%%\"*}
}

#函数---显示安装结束后的配置信息
function print_result_info() {
	
	echo -e "\n"
	echo "============================================================"
	echo "节点1--->"
	echo "协议: "$1
	echo "端口: 9800"
	echo "用户id: af41686b-cb85-494a-a554-eeaa1514bca7"
	echo "加密方式: none"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b5-002"
	echo "复制以下链接到VPN客户端"
#	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@1.2.2.2:9800?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b5-002#%E8%90%BD%E5%9C%B0%E6%9C%BA"
	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9800?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b5-002#MyVless"

	echo -e "\n"

	echo "节点2--->"
	echo "协议: "$1
	echo "端口: 9800"
	echo "用户id: af41686b-cb85-494a-a554-eeaa1514bca7"
	echo "加密方式: none"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b5-003"
	echo "复制以下链接到VPN客户端"
	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9800?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b5-003#MyVless"	

	echo "============================================================"
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

protocol_choice="vless"

#echo "安装依赖包"
#apt update -y && apt install -y netcat && apt install -y net-tools && apt install -y curl && apt install -y socat && apt install -y wget && apt install -y unzip && apt install -y ufw
apt update -y

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
wget -O jiedian.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/vless-two-ws.json
rm /usr/local/etc/v2ray/config.json
cp jiedian.json /usr/local/etc/v2ray/config.json

echo "安装nginx"
apt install -y nginx

echo "下载nginx配置文件"
rm nginx.conf
wget -O nginx2.conf https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/nginx/nginx2.conf
rm /etc/nginx/nginx.conf
cp nginx2.conf /etc/nginx/nginx.conf
chmod 777 /etc/nginx/nginx.conf

#启用bbr
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf && echo "net.ipv4.tcp_congestion_control= bbr" >> /etc/sysctl.conf&& sysctl -p

echo "重启v2ray nginx"
systemctl restart v2ray.service
systemctl restart nginx.service

#设置开机启动(v2ray需要设置，nginx本身就会自启动)
sudo systemctl enable v2ray.service
sudo systemctl enable nginx.service

echo -e "\n\n\n"
echo "安装完成！！！！！！！！"

#获取ip
my_ip="1.2.2.2"
get_my_ip

print_result_info $protocol_choice
