#!/bin/bash

#爬取ipinfo.io获取信息
full_ipinfo=$(curl ipinfo.io)

#截取"ip":之前内容，要用转义字符
ipinfo=${full_ipinfo#*\"ip\":}

#截取"之前内容，要用转义字符
ipinfo=${ipinfo#*\"}

#截取"之后的内容，要用转义字符，注意*号位置和之前不同
ipinfo=${ipinfo%%\"*}

nameserver="nameserver "${ipinfo}

echo ${nameserver} > /etc/resolv.conf

echo ${full_ipinfo}
echo -e "\n\n\n"
echo "公网IP: "${ipinfo}
echo "写入内容: "${nameserver}
echo "/etc/resolv.conf已经更新"

#echo -e "\033[32m主机重启或者网络服务重启需要运行此脚本，或设为开机启动\033[0m"
