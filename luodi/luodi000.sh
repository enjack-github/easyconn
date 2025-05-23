#!/bin/bash

#一键安装脚本
#wget -O luodi000.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi000.sh && bash luodi000.sh
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

#函数--获取用户id，存在则直接读取，不存在则用系统uuid
function get_user_id() {
	#读取id记录文件
	my_user_id=''
	while read line
	do
	    echo $line
	    my_user_id=${my_user_id}${line}
	done < .v2_config/user_id.txt
	
	
	#判断长度
	if [ ${#my_user_id} -gt 5 ]; then
		echo "read user id from file correct. length>5"
     else
     	echo "read user id from file fault"
     	echo "read from system random uuid"
     	#文件中没有id，就从系统读取。刚好是8-4-4-4-12格式
     	my_user_id=$(cat /proc/sys/kernel/random/uuid)
     	#保存id到文件
     	mkdir .v2_config
     	echo ${my_user_id} > .v2_config/user_id.txt
	fi
	echo "user id is: "${my_user_id}	
}


#函数---常用节点
function print_usefull_inbounds() {
	echo -e "\e[32m*** luodi3 vless+ws+ng *** \e[0m     (适合直连)"
	echo "端口: 9800"
	echo "用户id: af41686b-cb85-494a-a554-eeaa1514bca7"
	echo "加密方式: none"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b5-002"
	echo "链接:"
	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9800?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b5-002#luodi3-9800"	

	echo -e "\n"
	echo -e "\e[32m*** vmess+tcp *** \e[0m     (适合上中转)"
	echo "端口: 32020"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	vmess_str='{"v": "2","ps": "vmess+tcp","add": "'${my_ip}'","port": "32020","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "none","net": "tcp","type": "none","host": "","path": "","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}

	echo -e "\n"
	echo -e "\e[32m*** vmess+tcp 随机id *** \e[0m     (适合上中转  随机user id)"
	echo "端口: 32030"
	echo "用户id: "${my_user_id}
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	vmess_str='{"v": "2","ps": "vmess+tcp+RandomUserID","add": "'${my_ip}'","port": "32030","id": "'${my_user_id}'","aid": "0","scy": "none","net": "tcp","type": "none","host": "","path": "","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}	

	echo -e "\n"
	echo -e "\e[32m*** vless+tcp 随机id *** \e[0m     (适合上中转  随机user id)"
	echo "端口: 32031"
	echo "用户id: "${my_user_id}
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	echo "vless://"${my_user_id}"@"${my_ip}":32031?encryption=none&security=none&type=tcp&headerType=none#vless%2Btcp"
	echo "============================================================"
}

#函数---动态路径节点
function print_dynamic_path_inbounds() {
	echo -e "\e[32m*** luodi3 vless+ws+ng 动态路径*** \e[0m"
	echo "端口: 9900"
	echo "用户id: af41686b-cb85-494a-a554-eeaa1514bca7"
	echo "加密方式: none"
	echo "传输协议: ws"
	echo "路径: /"$ip_base64
	echo "链接:"
	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9900?encryption=none&security=none&type=ws&path=%2F$ip_base64#luodi3-9900"	

	echo -e "\n"
	echo -e "\e[32m*** luodi7 vmess+ws+ng 动态路径*** \e[0m"
	echo "端口: 35570"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: ws"
	echo "路径: /${ip_base64}"
	echo "链接:"
	vmess_str='{"v": "2","ps": "luodi7-vmess+ws+ng-path","add": "'${my_ip}'","port": "35570","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "ws","type": "none","host": "","path": "/'${ip_base64}'","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}		
	echo "============================================================"
}

#函数---
function print_luodi3_inbounds() {
	echo -e "\e[32m*** luodi3 vless+ws+ng *** \e[0m"
	echo "端口: 9800"
	echo "用户id: af41686b-cb85-494a-a554-eeaa1514bca7"
	echo "加密方式: none"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b5-002"
	echo "链接:"
	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9800?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b5-002#luodi3-9800"	
	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9800?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b5-002#luodi3-9800"	>> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** luodi3 vless+ws+ng 动态路径*** \e[0m"
	echo "端口: 9900"
	echo "用户id: af41686b-cb85-494a-a554-eeaa1514bca7"
	echo "加密方式: none"
	echo "传输协议: ws"
	echo "路径: /"$ip_base64
	echo "链接:"
	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9900?encryption=none&security=none&type=ws&path=%2F$ip_base64#luodi3-9900"
	echo "vless://af41686b-cb85-494a-a554-eeaa1514bca7@"${my_ip}":9900?encryption=none&security=none&type=ws&path=%2F$ip_base64#luodi3-9900"		>> allinbounds.txt
	echo "============================================================"
}

#函数---
function print_luodi5_inbounds() {
	echo -e "\e[32m*** luodi5 vmess+tcp *** \e[0m"
	echo "端口: 35510"
	echo "用户id: af01686b-cb85-293a-a557-eeaa1519bca8"
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	vmess_str='{"v": "2","ps": "luodi5-vmess+tcp","add": "'${my_ip}'","port": "35510","id": "af01686b-cb85-293a-a557-eeaa1519bca8","aid": "0","scy": "none","net": "tcp","type": "none","host": "","path": "","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}
	echo ${vmess_str} >> allinbounds.txt
	echo "============================================================"
}


#函数---
function print_luodi6_inbounds() {
	echo -e "\e[32m*** luodi6 ss+tcp *** \e[0m"
	echo "端口: 35520"
	echo "密码: b25b63c585a0987d6"
	echo "加密方式: chacha20-ietf-poly1305"
	echo "传输协议: tcp"
	echo "链接:"
	ss_str='chacha20-ietf-poly1305:b25b63c585a0987d6'
	ss_str='ss://'$(echo $ss_str | base64)"@"${my_ip}":35520#luodi6-ss+tcp"
	echo ${ss_str}
	echo ${ss_str} >> allinbounds.txt
	echo "============================================================"
}

#函数---
function print_luodi7_inbounds() {
	echo -e "\e[32m*** luodi7 vmess+ws+ng *** \e[0m"
	echo "端口: 35560"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b5-002"
	echo "链接:"
	vmess_str='{"v": "2","ps": "luodi7-vmess+ws+ng","add": "'${my_ip}'","port": "35560","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "ws","type": "none","host": "","path": "/ab596b5a5d3636b5-002","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}
	echo ${vmess_str} >> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** luodi7 vmess+ws+ng 动态路径*** \e[0m"
	echo "端口: 35570"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: ws"
	echo "路径: /${ip_base64}"
	echo "链接:"
	vmess_str='{"v": "2","ps": "luodi7-vmess+ws+ng-path","add": "'${my_ip}'","port": "35570","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "ws","type": "none","host": "","path": "/'${ip_base64}'","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}
	echo ${vmess_str} >> allinbounds.txt
	echo "============================================================"
}

#函数---显示ss节点
function print_ss_inbounds() {
	echo -e "\e[32m*** ss+tcp *** \e[0m"
	echo "端口: 38010"
	echo "密码: b25b63c585a0987d6"
	echo "加密方式: chacha20-ietf-poly1305"
	echo "传输协议: tcp"
	echo "链接:"
	ss_str='chacha20-ietf-poly1305:b25b63c585a0987d6'
	ss_str='ss://'$(echo $ss_str | base64)"@"${my_ip}":38010#ss+tcp"
	echo ${ss_str}	
	echo ${ss_str}	>> allinbounds.txt

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
	echo ${ss_str}	>> allinbounds.txt	

	echo -e "\n"
	echo -e "\e[32m*** ss+tcp+ng *** \e[0m"
	echo "端口: 32013"
	echo "密码: b25b63c585a0987d6"
	echo "加密方式: chacha20-ietf-poly1305"
	echo "传输协议: tcp"
	echo "链接:"
	ss_str='chacha20-ietf-poly1305:b25b63c585a0987d6'
	ss_str='ss://'$(echo $ss_str | base64)"@"${my_ip}":32013#ss+tcp+ng"
	echo ${ss_str}	
	echo ${ss_str}	>> allinbounds.txt
	
	echo -e "\n"
	echo -e "\e[32m*** ss+ws+ng *** (由于ss链接不带传输协议等参数，该链接复制到客户端后需要再手动选择ws和路径) \e[0m"
	echo "端口: 32014"
	echo "密码: b25b63c585a0987d6"
	echo "加密方式: chacha20-ietf-poly1305"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b579bc0d2f000"
	echo "链接:"
	ss_str='chacha20-ietf-poly1305:b25b63c585a0987d6'
	ss_str='ss://'$(echo $ss_str | base64)"@"${my_ip}":32014#ss+ws+ng"
	echo ${ss_str}	
	echo ${ss_str}	>> allinbounds.txt
	echo "============================================================"
}

#函数---
function print_vless_inbounds() {
	echo -e "\e[32m*** vless+tcp *** \e[0m"
	echo "端口: 32015"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32015?encryption=none&security=none&type=tcp#vless+tcp"
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32015?encryption=none&security=none&type=tcp#vless+tcp"	>> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** vless+ws *** \e[0m"
	echo "端口: 32016"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: none"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b579bc0d2f000"
	echo "链接:"
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32016?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b579bc0d2f000#vless+ws"	
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32016?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b579bc0d2f000#vless+ws" >> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** vless+tcp+ng *** \e[0m"
	echo "端口: 32017"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32017?encryption=none&security=none&type=tcp#vless+tcp+ng"
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32017?encryption=none&security=none&type=tcp#vless+tcp+ng" >> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** vless+ws+ng *** \e[0m"
	echo "端口: 32018"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: none"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b579bc0d2f000"
	echo "链接:"
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32018?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b579bc0d2f000#vless+ws+ng"	
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32018?encryption=none&security=none&type=ws&path=%2Fab596b5a5d3636b579bc0d2f000#vless+ws+ng" >> allinbounds.txt	

	echo -e "\n"
	echo -e "\e[32m*** vless+kcp(易被墙) *** \e[0m"
	echo "端口: 32019"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: none"
	echo "传输协议: kcp"
	echo "kcp seed:c25785a6987d235897"
	echo "链接:"
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32019?encryption=none&security=none&type=kcp&headerType=none&seed=c25785a6987d235897#*vless+kcp"		
	echo "vless://af61686b-cb85-293a-a559-eeaa1510bca7@"${my_ip}":32019?encryption=none&security=none&type=kcp&headerType=none&seed=c25785a6987d235897#*vless+kcp"	>> allinbounds.txt	

	echo -e "\n"
	echo -e "\e[32m*** vless+tcp 随机id *** \e[0m     (适合上中转  随机user id)"
	echo "端口: 32031"
	echo "用户id: "${my_user_id}
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	echo "vless://"${my_user_id}"@"${my_ip}":32031?encryption=none&security=none&type=tcp&headerType=none#vless%2Btcp"		
	echo "vless://"${my_user_id}"@"${my_ip}":32031?encryption=none&security=none&type=tcp&headerType=none#vless%2Btcp"	>> allinbounds.txt
	echo "============================================================"
}

#函数---
function print_vmess_inbounds() {	
	echo -e "\e[32m*** vmess+tcp *** \e[0m"
	echo "端口: 32020"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	vmess_str='{"v": "2","ps": "vmess+tcp","add": "'${my_ip}'","port": "32020","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "none","net": "tcp","type": "none","host": "","path": "","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}
	echo ${vmess_str} >> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** vmess+ws *** \e[0m"
	echo "端口: 32021"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b579bc0d2f000"
	echo "链接:"
	vmess_str='{"v": "2","ps": "vmess+ws","add": "'${my_ip}'","port": "32021","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "ws","type": "none","host": "","path": "/ab596b5a5d3636b579bc0d2f000","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}	
	echo ${vmess_str} >> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** vmess+tcp+ng *** \e[0m"
	echo "端口: 32022"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	vmess_str='{"v": "2","ps": "vmess+tcp+ng","add": "'${my_ip}'","port": "32022","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "none","net": "tcp","type": "none","host": "","path": "","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}
	echo ${vmess_str} >> allinbounds.txt	

	echo -e "\n"
	echo -e "\e[32m*** vmess+ws+ng *** \e[0m"
	echo "端口: 32023"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b579bc0d2f000"
	echo "链接:"
	vmess_str='{"v": "2","ps": "vmess+ws+ng","add": "'${my_ip}'","port": "32023","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "ws","type": "none","host": "","path": "/ab596b5a5d3636b579bc0d2f000","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}	
	echo ${vmess_str} >> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** vmess+kcp(易被墙) *** \e[0m"
	echo "端口: 32024"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: kcp"
	echo "kcp seed:c25785a6987d235897"
	echo "链接:"
	vmess_str='{"v": "2","ps": "*vmess+kcp","add": "'${my_ip}'","port": "32024","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "kcp","type": "none","host": "","path": "c25785a6987d235897","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}	
	echo ${vmess_str} >> allinbounds.txt

	echo -e "\n"
	echo -e "\e[32m*** vmess+kcp+ng *** \e[0m"
	echo "端口: 32027"
	echo "用户id: af61686b-cb85-293a-a559-eeaa1510bca7"
	echo "加密方式: auto"
	echo "传输协议: kcp"
	echo "kcp seed:c25785a6987d235897"
	echo "链接:"
	vmess_str='{"v": "2","ps": "vmess+kcp+ng","add": "'${my_ip}'","port": "32027","id": "af61686b-cb85-293a-a559-eeaa1510bca7","aid": "0","scy": "auto","net": "kcp","type": "none","host": "","path": "c25785a6987d235897","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}	
	echo ${vmess_str} >> allinbounds.txt	

	echo -e "\n"
	echo -e "\e[32m*** vmess+tcp 随机id *** \e[0m     (适合上中转  随机user id)"
	echo "端口: 32030"
	echo "用户id: "${my_user_id}
	echo "加密方式: none"
	echo "传输协议: tcp"
	echo "链接:"
	vmess_str='{"v": "2","ps": "vmess+tcp+RandomUserID","add": "'${my_ip}'","port": "32030","id": "'${my_user_id}'","aid": "0","scy": "none","net": "tcp","type": "none","host": "","path": "","tls": "","sni": "","alpn": ""}'
	vmess_str='vmess://'$(echo $vmess_str | base64)
	echo ${vmess_str}		
	echo ${vmess_str} >> allinbounds.txt	
	echo "============================================================"
}

#函数---
function print_socks5_inbounds() {
	echo -e "\n"
	echo -e "\e[32m*** socks5+tcp *** (该节点端口默认关闭) \e[0m"
	echo "端口: 32025"
	echo "用户名: a25b03c5a01872000"
	echo "密码: b25b63c585a0987d6"
	echo "传输协议: tcp"
	echo -e "\e[32m*** 该节点为经过连通测试，可能是socks明文传输被墙，为防止探测，该节点端口默认关闭 \e[0m"			
	echo "============================================================"
}

#函数---
function print_trojan_inbounds() {
	echo -e "\n"
	echo -e "\e[32m*** trojan+tls *** \e[0m(记得手动设置跳过证书验证为true, 链接中不带此参数)"
	echo "端口: 32028"
	echo "密码: b25b63c585a0987d6"
	echo "传输协议: tcp"
	echo "跳过证书验证: true"
	echo "alpn: http 1.1"
	echo "链接:"
	echo "trojan://b25b63c585a0987d6@"${my_ip}":32028?security=tls&alpn=http%2F1.1&type=tcp&headerType=none#trojan%2Btls%2B%E8%87%AA%E7%AD%BE%E8%AF%81%E4%B9%A6"
	echo "trojan://b25b63c585a0987d6@"${my_ip}":32028?security=tls&alpn=http%2F1.1&type=tcp&headerType=none#trojan%2Btls%2B%E8%87%AA%E7%AD%BE%E8%AF%81%E4%B9%A6" >> allinbounds.txt	

	echo -e "\n"
	echo -e "\e[32m*** trojan+ws+tls *** \e[0m(记得手动设置跳过证书验证为true, 链接中不带此参数)"
	echo "端口: 32029"
	echo "密码: b25b63c585a0987d6"
	echo "传输协议: ws"
	echo "路径: /ab596b5a5d3636b579bc0d2f000"
	echo "跳过证书验证: true"
	echo "alpn: http 1.1"
	echo "链接:"
	echo "trojan://b25b63c585a0987d6@"${my_ip}":32029?security=tls&alpn=http%2F1.1&type=ws&path=%2Fab596b5a5d3636b579bc0d2f000#trojan%2Bws%2Btls%2B%E8%87%AA%E7%AD%BE%E8%AF%81%E4%B9%A6"
	echo "trojan://b25b63c585a0987d6@"${my_ip}":32029?security=tls&alpn=http%2F1.1&type=ws&path=%2Fab596b5a5d3636b579bc0d2f000#trojan%2Bws%2Btls%2B%E8%87%AA%E7%AD%BE%E8%AF%81%E4%B9%A6" >> allinbounds.txt					
	echo "============================================================"
}

#函数---
function print_hysteria_inbounds() {
	echo -e "\n"
	echo -e "\e[32m*** hysteria *** (流量大易被墙)\e[0m"
	echo "端口: 32026"
	echo "密码: b25b63c585a0987d6"		
	echo "insecure: true (自签证书)"			
	echo "============================================================"
}


#函数---显示所有节点
function print_all_inbounds() {
	get_my_ip

	rm allinbounds.txt
	echo -e "所有节点:\n\n" > allinbounds.txt
	echo "============================================================"
	print_ss_inbounds
	print_vless_inbounds
	print_vmess_inbounds
	print_socks5_inbounds
	print_trojan_inbounds
	print_hysteria_inbounds
	print_luodi3_inbounds
	print_luodi5_inbounds
	print_luodi6_inbounds
	print_luodi7_inbounds
	print_dynamic_path_inbounds
	print_usefull_inbounds

	if [[ $1 == "install_finish" ]];then
		if [[ $(ufw status) =~ "inactive" ]];then
			echo -e "ufw未激活"
		else
			echo -e "\e[34;46m 防火墙已激活 \e[0m"
		fi
		echo -e "\e[33;40m 安装完成！！！！！！！！\e[0m 再次运行脚本选择2查看各个节点"
		exit 0
	fi	

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
	echo "8) 兼容luodi6.sh节点"
	echo "9) 兼容luodi7.sh节点"
	echo "10) socks5节点"
	echo "11) trojan节点"
	echo "12) hysteria节点"	
	read -r -p "请输入数字选择(直接按回车键返回上级): " input
	case $input in
	    0) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_usefull_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input			
	    		continue
	    		;;
	    1) 
			rm allinbounds.txt
			echo -e "所有节点:\n\n" > allinbounds.txt
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
    			print_ss_inbounds
			print_vless_inbounds
			print_vmess_inbounds
			print_socks5_inbounds
			print_trojan_inbounds
			print_hysteria_inbounds
			print_luodi3_inbounds
			print_luodi5_inbounds
			print_luodi6_inbounds
			print_luodi7_inbounds
			print_dynamic_path_inbounds
			print_usefull_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input			
	    		continue
	    		;;	    		
	    2) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
			print_dynamic_path_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input			
	    		continue
	    		;;
	    3) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_luodi3_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;    		
	    4) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_luodi5_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;   
	    5) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_ss_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;
	    6) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_vless_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;
	    7) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_vmess_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;
	    8) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_luodi6_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;   
	    9) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_luodi7_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;  	 
	    10) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_socks5_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;  	 
	    11) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_trojan_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
	    		continue
	    		;;  	   
	    12) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n"
	    		print_hysteria_inbounds
	    		echo -e "\e[33m 回车键返回菜单 \e[0m\c"
	    		read -r -p "" input
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


#函数---ufw设置
function ufw_setting() {
	echo "设置ufw"
	ufw allow ssh
	#luodi3 vless+ws+ng
	ufw allow 9800
	ufw allow 9900
	#luodi5 vmess+tcp
	ufw allow 35510
	#luodi6 ss+tcp
	ufw allow 35520
	#luodi7 vmess+ws+ng
	ufw allow 35560
	ufw allow 35570
	ufw allow 80
	#ss+tcp
	ufw allow 38010
	#ss+ws
	ufw allow 32012
	#ss+tcp+ng
	ufw allow 32013
	#ss+ws+ng
	ufw allow 32014
	#vless+tcp
	ufw allow 32015
	#vless+ws
	ufw allow 32016
	#vless+tcp+ng
	ufw allow 32017
	
	#vless+ws+ng
	ufw allow 32018
	#vless+kcp
	ufw allow 32019	
	#vmess+tcp
	ufw allow 32020	
	#vmess+ws
	ufw allow 32021
	
	#vmess+tcp+ng
	ufw allow 32022
	#vmess+ws+ng
	ufw allow 32023
	#vmess+kcp
	ufw allow 32024
	#socks5+tcp (安全问题，关闭端口)	
	ufw delete allow 32025
	ufw deny 32025
	#hysteria(大流量会被墙)
	ufw allow 32026
	#vmess+kcp+ng
	ufw allow 32027
	#trojan+tls
	ufw allow 32028
	#trojan+ws+tls
	ufw allow 32029

	#vmess+tcp 随机user id
	ufw allow 32030

	#vless_tcp 随机user id
	ufw allow 32031
	
	echo -e "\e[31;46m准备开启防火墙...  Attemp to enable ufw \e[0m   选择y打开ufw, 选择n保持现状"
	sudo ufw enable
}


#函数---安装节点
function install_my_service() {
	#判断是否是root用户
	if [ $(whoami) == "root" ]; then
		echo "current user is root."	
	else
		echo -e "\e[33m当前非root用户，请使用root用户运行此脚本\e[0m"
		exit 0
	fi
	
	#判断是否首次运行，首次则安装依赖包
	if [ -f "/root/.first_run_luodi_script" ];then
		echo "tag file exist, do not need install tools"
	else 
		echo "首次运行,安装工具依赖"
		apt update -y && apt install -y netcat && apt install -y net-tools && apt install -y curl && apt install -y socat && apt install -y wget && apt install -y unzip && apt install -y ufw
		touch /root/.first_run_luodi_script
	fi
	
	#echo "安装依赖包"
	#apt update -y && apt install -y netcat && apt install -y net-tools && apt install -y curl && apt install -y socat && apt install -y wget && apt install -y unzip && apt install -y ufw
	#apt update -y
	
	#安装curl
	#apt install -y curl
	
	wget -O checksh.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/checksh.sh
	
	#获取ip
	my_ip="1.2.2.2"
	get_my_ip

	#获取user id
	get_user_id

	#自签证书
	echo "安装自签证书"
	mkdir /root/ssl
	mkdir /root/ssl/self
	openssl ecparam -genkey -name prime256v1 -out /root/ssl/self/ca.key
	openssl req -new -x509 -days 36500 -key /root/ssl/self/ca.key -out /root/ssl/self/ca.crt  -subj "/CN=bing.com"
	chmod 777 /root/ssl/self/ca.key
	chmod 777 /root/ssl/self/ca.crt

	echo "停止服务"
	systemctl disable v2ray.service
	systemctl stop v2ray.service
	systemctl disable nginx.service
	systemctl stop nginx.service
	systemctl disable hysteria-server.service
	systemctl stop hysteria-server.service
	
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
	rm v2ray-install-release.sh
	
	echo "下载v2ray.service文件"
	wget -O v2ray.service https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/v2ray.service
	rm /etc/systemd/system/v2ray.service
	cp v2ray.service /etc/systemd/system/v2ray.service
	systemctl daemon-reload
	rm v2ray.service
	
	echo "下载节点配置文件"
	rm jiedian.json
	wget -O jiedian.json https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/v2ray/config/luodi000-all.json
	rm /usr/local/etc/v2ray/config.json
	cp jiedian.json /usr/local/etc/v2ray/config.json
	rm jiedian.json
	#用当前ip的base64编码，作为ws路径
	sed -i "s/replace-with-you-path/$ip_base64/g" /usr/local/etc/v2ray/config.json
	#替换user id
	sed -i "s/replace-with-you-uuid/$my_user_id/g" /usr/local/etc/v2ray/config.json
	
	echo "安装nginx"
	apt install -y nginx
	
	echo "下载nginx配置文件"
	rm nginx.conf
	wget -O nginx.conf https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/nginx/nginx000.conf
	rm /etc/nginx/nginx.conf
	cp nginx.conf /etc/nginx/nginx.conf
	chmod 777 /etc/nginx/nginx.conf
	#用当前ip的base64编码，作为ws路径
	sed -i "s/replace-with-you-path/$ip_base64/g" /etc/nginx/nginx.conf
	rm nginx.conf

	#安装hysteria
	bash <(curl -fsSL https://get.hy2.sh/)

	#复制证书到hysteria目录，否则hystetia没有权限读取/root下的证书文件
	mkdir /etc/hysteria/ssl
	mkdir /etc/hysteria/ssl/self
	cp /root/ssl/self/ca.crt /etc/hysteria/ssl/self/ca.crt
	cp /root/ssl/self/ca.key /etc/hysteria/ssl/self/ca.key
	chmod 777 /etc/hysteria/ssl/self/ca.crt
	chmod 777 /etc/hysteria/ssl/self/ca.key
	
	wget -O /etc/hysteria/config.yaml https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/hysteria/config/config-luodi000.yaml
	chmod 777 /etc/hysteria/config.yaml
	
	#启用bbr
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf && echo "net.ipv4.tcp_congestion_control= bbr" >> /etc/sysctl.conf&& sysctl -p
	
	echo "重启服务"
	sudo systemctl restart v2ray.service
	sudo systemctl restart nginx.service
	#默认不开启hysteria
	#sudo systemctl restart hysteria-server.service
	sudo systemctl disable hysteria-server.service
	sudo systemctl stop hysteria-server.service
	
	#设置开机启动(v2ray需要设置，nginx本身就会自启动)
	sudo systemctl enable v2ray.service
	sudo systemctl enable nginx.service
	#sudo systemctl enable hysteria-server.service
	
	ufw_setting
	
	print_all_inbounds "install_finish"
}


#函数---主菜单
function main_menu() {
#	if [[ $(dpkg --get-selections | grep cowsay) =~ "install" ]];then
#	    cowsay "All you own is none"
#	else
#	    apt install -y cowsay
#	    cowsay "All you own is none" 
#	fi

	echo -e "\e[33;46m\n                                                                           \e[0m"
	echo -e "\e[35;46m                                   合集                                    \e[0m"
	echo -e "\e[33;46m                                                                           \e[0m"
	
	#cp luodi000.sh tools.sh
	#chmod 777 tools.sh
	
	while true
	do
	echo -e "\e[33m\n【一键脚本合集】luodi000 \e[0m"
	echo -e "选择以下脚本功能---"
	echo "1) 安装"
	echo "2) 查看节点配置"
	echo "3) 重启服务"
	echo "4) 查看v2ray运行状态		5) 查看v2ray配置文件"
	echo "6) 查看nginx运行状态		7) 查看nginx配置文件"
	echo "8) 查看hysteria运行状态		9) 查看hysteria配置文件"
	read -r -p "请输入数字选择(直接按回车键退出脚本): " input
	case $input in
	    1) 
	    		echo "开始安装"
       			while true
	  		do
     				sleep 1
	 		done
	    		install_my_service
	    		break
	    		;;
	    2) 
	    		echo -e "\n\n\n\n\n\n\n\n\n\n\n\n"
	      	get_my_ip
	      	get_user_id
	    		print_all_inbounds
	    		continue
	    		;;
	    3) 
	    		systemctl restart v2ray
	    		systemctl restart nginx
	    		systemctl restart hysteria-server.service
	    		echo -e "\e[1;36m\n服务已重启\e[0m"
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
	    8) 
	    		systemctl status hysteria-server.service
	    		continue
	    		;;
	    9) 
	    		cat /etc/hysteria/config.yaml
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

