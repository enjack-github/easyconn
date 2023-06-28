#!/bin/bash

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
	echo "已经添加覆写脚本任务到列表"
}

#安装dns工具，用于各种测试
apt-get install -y dnsutils

#安装bind9
apt-get install -y bind9

#下载named.conf.options配置文件
echo "下载named.conf.options配置文件"
rm named.conf.options
echo -e "\n选择地区---"
echo "1) 马来西亚"
echo "2) 泰国"
echo "3) 印尼"
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

add_crontab
systemctl start bind9
