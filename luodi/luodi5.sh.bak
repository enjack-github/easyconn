#!/bin/bash

#一键安装脚本
#wget -O luodi5.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi5.sh && sudo bash luodi5.sh
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

	#当前IP的base64编码
	ip_base64=$(echo $my_ip | base64)

	echo -e "\n"
 	echo ip is: $my_ip
	echo ip base64 is: $ip_base64	
 	echo -e "\n"
}

#函数---显示安装结束后的配置信息
function print_result_info() {
	echo -e "\n"

	echo "协议: "$1
	echo "端口: 35510"
	echo "用户id: af01686b-cb85-293a-a557-eeaa1519bca8"
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "复制以下链接到VPN客户端"
	#echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9900?encryption=none&security=none&type=ws&path=%2F$ip_base64#MyVless"
	vmess_str='{"v": "2","ps": "luodi5","add": "'${my_ip}'","port": "35510","id": "af01686b-cb85-293a-a557-eeaa1519bca8","aid": "0","scy": "none","net": "tcp","type": "none","host": "","path": "","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}

	echo "***********************************************************************************************"
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
echo -e "\n【vmess一键脚本】luodi5 vmess+tcp 35510"
echo -e "选择以下脚本功能---"
echo "1) 安装"
echo "2) 查看节点配置"
echo "3) 重启服务"
echo "4) 查看v2ray运行状态"
echo "5) 查看v2ray配置文件"
read -r -p "请输入数字选择: " input
case $input in
    1) 
    		echo "开始安装"
    		break
    		;;
    2) 
    		echo -e "\n\n\n\n\n\n\n\n\n\n\n\n"
      		get_my_ip
    		check_what_protocol_and_print
    		continue
    		;;
    3) 
    		systemctl restart v2ray
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
    *) 
    		echo "invalid option...退出脚本"
    		exit 1
    		;;
esac
done

protocol_choice="vmess"

#echo "安装依赖包"
#apt update -y && apt install -y netcat && apt install -y net-tools && apt install -y curl && apt install -y socat && apt install -y wget && apt install -y unzip && apt install -y ufw
apt update -y

#安装curl
apt install -y curl

wget -O checksh.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/checksh.sh

#获取ip
my_ip="1.2.2.2"
get_my_ip

#防火墙设置
echo "设置ufw"
ufw allow ssh
ufw allow 35510
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
wget -O jiedian.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/luodi5-vmess.json
rm /usr/local/etc/v2ray/config.json
cp jiedian.json /usr/local/etc/v2ray/config.json


#启用bbr
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf && echo "net.ipv4.tcp_congestion_control= bbr" >> /etc/sysctl.conf&& sysctl -p

echo "重启v2ray"
systemctl restart v2ray.service

#设置开机启动(v2ray需要设置)
sudo systemctl enable v2ray.service


echo -e "\n\n\n"
echo "安装完成！！！！！！！！"

print_result_info $protocol_choice
