#!/bin/bash
# @Author: Aliao  
# @Repository: https://github.com/vod-ka   
# @Date: 2021-03-09 16:10:09  
# @Last Modified by:   Aliao  
# @Last Modified time: 2021-03-09 16:10:09
 
#升级kali系统和清楚旧包

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/bin
export PATH
cutimer=$(date  +'%Y%m%d%H%M')
cumonth=$(date +%m)
cuyear=$(date +%Y)
udlog="system_update_$cutimer.log"
basedst="$HOME/update_log"
logdst="${basedst}/${cuyear}/${cumonth}"
kcmd="aptitude"
#If you're running the script as a normal user, you'll need to assign your Password to the Password variable
Password="hjkl;'"      #You password

Blue(){
    echo -e "\033[34;01m$1\033[0m"
}

Red(){
    echo -e "\033[31;01m$1\033[0m"
}

check_dst(){
    if [ -d "$logdst" ]
    then
        Blue "-------------------------\nThe task of System update  is running ...\n$(date "+%F %T")" > "$logdst"/"$udlog"
    else
        mkdir -p "$basedst"/"$cuyear"/"$cumonth"
        Blue "-------------------------\nThe path of log does not exist, creating now...\n$(date "+%F %T")" >> "$basedst"/error.log
    fi
}

check_network(){
    ping -c 1 mirrors.aliyun.com > /dev/null 2>&1
    local a=$?
    ping -c 1 mirrors.tuna.tsinghua.edu.cn > /dev/null 2>&1
    local b=$?
    if [ $a -eq 0 ] || [ $b -eq 0 ] 
    then
        Blue "-------------------------\nNetwork connection is fine, system is updating!\n$(date "+%F %T")"
    else
        Red "-------------------------\nThe device is offline, please check whether the network connection is normal!\nSystem update task failed!\n$(date "+%F %T")"
        exit 1
    fi
}

Action (){
    echo "$Password" | sudo -S $kcmd "$1" -y
}

check_user(){
    if [ $(id -u) != 0 ]
    then
        common_user
    else
        root_user
    fi    
}

check_aptitude(){
    if ! aptitude -h > /dev/null 2>&1;
    then
        if [ $(id -u) = 0 ]
        then
            apt-get install -y aptitude
        else
            local kcmd="apt-get"
            Action install aptitude
        fi
    fi
}

common_user(){
    echo
    Red "-------------------------"
    echo
    Action update
    Action safe-upgrade
    Blue "-------------------------\nSystem upgrade completed!\n$(date "+%F %T")"
    echo
    Red "-------------------------"
    echo
    Action clean
    local kcmd="apt-get"
    Action autoremove
    Blue "-------------------------\nMission all over\n$(date "+%F %T")"
}

root_user(){
    echo
    Red "-------------------------"
    echo
    aptitude update
    aptitude safe-upgrade -y
    Blue "-------------------------\nSystem upgrade completed!\n$(date "+%F %T")"
    echo
    Red "-------------------------"
    echo
    aptitude clean
    apt autoremove -y
    Blue "-------------------------\nMission all over\n$(date "+%F %T")"
}

Main(){
    check_network
    check_aptitude
    check_user
}

check_dst
Main >> "$logdst"/"$udlog"