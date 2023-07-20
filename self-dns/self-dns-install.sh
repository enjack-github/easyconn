#!/bin/bash

#wget -O self-dns-install.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/self-dns/self-dns-install.sh && sudo bash self-dns-install.sh
#一键搭建DNS脚本，使用自身作为dns缓存/转发服务器

function add_crontab() {
	#读取原来的内容到临时文件
	crontab -l > /tmp/ori_cron_list

	#判断是否要添加 自启动任务
	strings=$(cat /tmp/ori_cron_list)
	if [[ $strings =~ "@reboot /etc/rewrite.resolved.sh" ]];then
		echo "已经有自启动任务，不需要添加"
	else
		echo "@reboot /etc/rewrite.resolved.sh" >> /tmp/ori_cron_list
	fi

	
	#判断是否要添加 定时覆写任务
	strings=$(cat /tmp/ori_cron_list)
	if [[ $strings =~ "* * * * /etc/rewrite.resolved.sh" ]];then
		echo "已经有定时覆写任务，不需要添加"
	else
		echo "*/3 * * * * /etc/rewrite.resolved.sh" >> /tmp/ori_cron_list
	fi	
	
	crontab /tmp/ori_cron_list
	echo "已经添加覆写脚本任务到任务列表"
}

#脚本功能选择
while true
do
echo -e "\n选择以下脚本功能---"
echo "1) 安装"
echo "2) 重启服务"
echo "3) 查看bind运行状态"
echo "4) 查看bind配置文件"
echo "5) 查看/etc/resolv.conf"
echo "6) 运行nameserver覆写脚本"
echo "7) dig tiktok.com"
echo "8) tcpdump抓取dns"
read -r -p "请输入数字选择: " input
case $input in
    1) 
    		echo "开始安装"
    		break
    		;;
    2) 
		systemctl restart systemd-resolved.service
		systemctl restart bind9.service
		rm rewrite.resolved.sh
		wget -O rewrite.resolved.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/self-dns/rewrite.resolved.sh
		chmod 777 rewrite.resolved.sh
		./rewrite.resolved.sh	
		echo "服务已重启"	
    		continue
    		;;
    3) 
		systemctl status bind9
    		continue
    		;;    		
    4) 
    		cat /etc/bind/named.conf.options
    		continue
    		;;
    5) 
    		echo -e "\n/etc/resolv.conf内容如下："
    		cat /etc/resolv.conf
    		continue
    		;;
    6) 
		rm rewrite.resolved.sh
		wget -O rewrite.resolved.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/self-dns/rewrite.resolved.sh
		chmod 777 rewrite.resolved.sh
		./rewrite.resolved.sh
    		continue
    		;;   
    7) 
		dig tiktok.com
		dig tiktok.com
    		continue
    		;;  
    8) 
		tcpdump -nt -s 500 port domain
    		continue
    		;;     	   				
    *) 
    		echo "invalid option...退出脚本"
    		exit 1
    		;;
esac
done

#安装dns工具，用于各种测试
apt-get install -y dnsutils

#安装bind9
apt-get install -y bind9

#判断bind是否安装成功
if [ ! -f "/etc/bind/named.conf.options" ]; then
	echo "bind未安装成功，没有找到/etc/bind/named.conf.options"
	echo "退出安装"
	exit 1
fi


#下载named.conf.options配置文件
echo "下载named.conf.options配置文件"
rm named.conf.options
echo -e "\n选择地区---"
echo "1) 马来西亚"
echo "2) 泰国"
echo "3) 印尼"
echo "4) 台湾"
read -r -p "请输入数字选择: " input
case $input in
    1) 
    		
		wget -O named.conf.options https://raw.githubusercontent.com/enjack-github/easyconn/main/self-dns/bind-conf/my.conf
    		;;
    2) 
		wget -O named.conf.options https://raw.githubusercontent.com/enjack-github/easyconn/main/self-dns/bind-conf/th.conf
    		;;
    3) 
		wget -O named.conf.options https://raw.githubusercontent.com/enjack-github/easyconn/main/self-dns/bind-conf/id.conf
    		;;   	
    4) 
		wget -O named.conf.options https://raw.githubusercontent.com/enjack-github/easyconn/main/self-dns/bind-conf/tw.conf
    		;;   
    *) 
    		echo "invalid option...退出脚本"
    		exit 1
    		;;
esac
rm /etc/bind/named.conf.options
cp named.conf.options /etc/bind/named.conf.options

#下载覆写脚本
echo "下载覆写脚本"
rm rewrite.resolved.sh
wget -O rewrite.resolved.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/self-dns/rewrite.resolved.sh
rm /etc/rewrite.resolved.sh
cp rewrite.resolved.sh /etc/rewrite.resolved.sh
chmod 777 /etc/rewrite.resolved.sh
chmod 777 rewrite.resolved.sh
./rewrite.resolved.sh 

add_crontab
systemctl start bind9

echo "dns服务安装完成，已更改DNS为本机地址"
