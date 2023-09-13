#!/bin/bash

#一键安装脚本
#wget -O luodi000.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi000.sh && sudo bash luodi000.sh
#nginx监听两个端口，两个端口(服务)内容一摸一样，一个作为备用线路
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
	echo "============================================================"
	echo "节点1--->"
	echo "协议: "$1
	echo "端口: 35560"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b5-002"
	echo "复制以下链接到VPN客户端"
	vmess_str='{"v": "2","ps": "luodi7","add": "'${my_ip}'","port": "35560","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "ws","type": "none","host": "","path": "/ab596b5a5d3636b5-002","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}

	echo -e "\n"

	echo "节点2--->"
	echo "协议: "$1
	echo "端口: 35570"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: ws"
	echo "路径: /${ip_base64}"
	echo "复制以下链接到VPN客户端"
	vmess_str='{"v": "2","ps": "luodi7","add": "'${my_ip}'","port": "35570","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "ws","type": "none","host": "","path": "/'${ip_base64}'","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}

	echo "============================================================"
	echo -e "\n\n"
}

#函数---显示ss节点
function print_ss_inbounds() {
	echo -e "\e[32m*** ss+tcp *** \e[0m"
	echo "端口: 32011"
	echo "密码: b25b63c585a0987d6"
	echo "加密方式: chacha20-ietf-poly1305"
	echo "传输协议: tcp"
	echo "链接:"
	ss_str='chacha20-ietf-poly1305:b25b63c585a0987d6'
	ss_str='ss://'$(echo $ss_str | base64)"@"${my_ip}":32011#ss+tcp"
	echo ${ss_str}	

	echo -e "\n"
	echo -e "\e[32m*** ss+ws *** (由于ss链接不带传输协议等参数，该链接复制到客户端后需要再手动选择ws和路径) \e[0m"
	echo "端口: 32012"
	echo "密码: b25b63c585a0987d6"
	echo "加密方式: chacha20-ietf-poly1305"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b579bc0d2f000"
	echo "链接:"
	ss_str='chacha20-ietf-poly1305:b25b63c585a0987d6'
	ss_str='ss://'$(echo $ss_str | base64)"@"${my_ip}":32012#ss+ws"
	echo ${ss_str}		

	echo -e "\n"
	echo "*** ss+tcp+ng *** (暂时不可用)"
	echo "*** ss+ws+ng *** (暂时不可用)"
	echo "============================================================"
}

#函数---
function print_vless_inbounds() {

	echo "============================================================"
}

#函数---
function print_vmess_inbounds() {

	echo "============================================================"
}


#函数---显示所有节点
function print_all_inbounds() {
	get_my_ip
	echo "============================================================"
	print_ss_inbounds
	print_vless_inbounds
	print_vmess_inbounds

	while true
	do
	echo -e "\e[33m输入数字选择需要显示的节点信息(其他返回主菜单)--- \e[0m"
	echo "0) 常用节点"
	echo "1) 所有节点"
	echo "2) 动态路径节点"
	echo "3) 兼容luodi3.sh节点"
	echo "4) 兼容luodi5.sh节点"
	echo "5) ss节点"
	echo "6) vless节点"
	echo "7) vmess节点"
	read -r -p "请输入数字选择: " input
	case $input in
	    0) 
	    		break
	    		;;
	    1) 
	    		break
	    		;;	    		
	    2) 

	    		continue
	    		;;
	    3) 
	    		continue
	    		;;    		
	    4) 
	    		continue
	    		;;
	    5) 
	    		print_ss_inbounds
	    		echo -e "\e[33m 按任意键返回选择 \e[0m\c"
	    		read -r -p "" input
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
	    		#echo "invalid option...退出脚本"
	    		#exit 1
	    		break
	    		;;
	esac
	done
}


#函数---安装节点
function install_my_service() {
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
	ufw allow 35560
	ufw allow 35570
	ufw allow 80
	
	ufw allow 32011
	ufw allow 32012
	ufw allow 32013
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
	wget -O jiedian.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/luodi7-vmess-ws.json
	rm /usr/local/etc/v2ray/config.json
	cp jiedian.json /usr/local/etc/v2ray/config.json
	#用当前ip的base64编码，作为ws路径
	sed -i "s/replace-with-you-path/$ip_base64/g" /usr/local/etc/v2ray/config.json
	
	echo "安装nginx"
	apt install -y nginx
	
	echo "下载nginx配置文件"
	rm nginx.conf
	wget -O nginx.conf https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/nginx/nginx7.conf
	rm /etc/nginx/nginx.conf
	cp nginx.conf /etc/nginx/nginx.conf
	chmod 777 /etc/nginx/nginx.conf
	#用当前ip的base64编码，作为ws路径
	sed -i "s/replace-with-you-path/$ip_base64/g" /etc/nginx/nginx.conf
	
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
	
	print_result_info $protocol_choice
}


#函数---主菜单
function main_menu() {
	while true
	do
	echo -e "\e[33m\n【一键脚本合集】luodi000 \e[0m"
	echo -e "选择以下脚本功能---"
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
	    		get_my_ip
	    		break
	    		;;
	    2) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n\n\n"
	      	get_my_ip
	    		print_all_inbounds
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
	    		echo -e "\e[36minvalid option...退出脚本\e[0m"
	    		exit 1
	    		;;
	esac
	done
}



#脚本功能选择
main_menu

protocol_choice="vmess"


