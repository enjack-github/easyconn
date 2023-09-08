#!/bin/bash

#一键安装脚本
#wget -O checksh.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/checksh.sh && sudo bash luodi5.sh


function print_result_info() {
	echo "------------------------------------------------------------------------------------------------"
	echo '当前使用的脚本是：'
	echo $1
	echo "------------------------------------------------------------------------------------------------"
	echo -e "\n\n"
}


function check_what_sh_and_print() {
	pro=$(cat /usr/local/etc/v2ray/config.json)
	if [[ $pro =~ "my_name_is:luodi6" ]];then
	    print_result_info "wget -O luodi6.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi6.sh && sudo bash luodi6.sh"
	elif [[ $pro =~ "my_name_is:luodi5" ]];then
		print_result_info "wget -O luodi5.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi5.sh && sudo bash luodi5.sh"
	elif [[ $pro =~ "my_name_is:luodi3" ]];then
		print_result_info "wget -O luodi3.sh https://raw.githubusercontent.com/enjack-github/easyconn/main/luodi/luodi3.sh && sudo bash luodi3.sh"
	else
	    print_result_info "unknown"
	fi
}

check_what_sh_and_print
