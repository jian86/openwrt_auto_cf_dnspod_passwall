#!/bin/bash
#####################################################################################################
##TG推送设置
#（填写即为开启推送，未填写则为不开启）
#TG机器人token 例如：123456789:ABCDEFG...
telegramBotToken=912320458:AAH_mSzRYfy13eDxvWsRwurA9p2x30EzhrU
#用户ID或频道、群ID 例如：123456789
telegramBotUserId=-4093558163
#####################################################################################################
#dnspod
#生成的loginToken填入此处
login_token="453642,3a5318cb800b2e06e40c64695c42e63c"
#将查询的domain_id填入此处
domain_id="27487406"
#将查询的记录id填入此处
record_id="1651950487"
# 解析类型，A为ipv4,AAAA为ipv6
record_type="A"
#将查询的对应的解析记录的前缀填入此处
sub_domain="edtunnel"
#####################################################################################################
#定义passwall节点名称
passwallnode=pY9G8QeR
#定义passwall进程
CLIEN=passwall
#####################################################################################################
#测速地址  
CFST_URL=https://cfspeed1.kkiyomi.top/200mb.bin
#####################################################################################################
start=`date +%s`
#####################################################################################################
#passwall
# echo "开始停止$CLIEN";
	# /etc/init.d/$CLIEN stop;
# echo "已停止$CLIEN";
#优选开始
current_time=$(date "+%Y-%m-%d %H:%M:%S")
echo "开始时间$current_time"
echo "开始优选IPv4"
./CloudflareST -url $CFST_URL -tl 200 -tll 40 -sl 5
echo "测速完毕"
echo "正在更新，请稍后..."
echo "获取优选后的ip地址"
ipAddr=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $1}')
echo "开始更新第$((x + 1))个---$ipAddr"
#####################################################################################################
#开始更新
curl -s -X POST https://dnsapi.cn/Record.Modify -d "login_token=$login_token&format=json&domain_id=$domain_id&record_id=$record_id&record_type=A&record_line=默认&sub_domain=$sub_domain&value=$ipAddr";
sleep 3s;
ip_addr_dns=`curl https://dnsapi.cn/Record.Info -d "login_token=${login_token}&format=json&domain_id=${domain_id}&record_id=${record_id}&remark="|awk -F '"value"' '{print $2}'|awk -F "\"" '{print $2}'`;
echo "3秒后继续"
sleep 3s;
#####################################################################################################
#开始重启
# /etc/init.d/$CLIEN restart;
# echo "已重启$CLIEN";
# #开始更新
uci set passwall.${passwallnode}.address=$ipAddr
uci commit passwall

#####################################################################################################
echo "EDtunnel域名优选IP设置为$ip_addr_dns"
echo "3秒后继续"
sleep 3s;

#定义passwall节点设置IP
ip=$(uci show passwall.${passwallnode}.address)
substring=${ip:26}
echo "passwall节点IP设置为$substring"

end=`date +%s.%N`
runtime=$(echo "$end - $start" | bc -l)
#停止时间
shutdown_time=$(date "+%Y-%m-%d %H:%M:%S")
#开始通知
message="EDtunnel优选通知：%0A开始时间$current_time%0AEDtunnel域名优选为'$ip_addr_dns'%0Apasswall节点设置为$substring%0A结束时间$shutdown_time%0A执行时长$runtime秒"
curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d chat_id=${telegramBotUserId}  -d parse_mode='HTML' -d text="$message"

echo "结束时间$shutdown_time"
echo "执行时长$runtime秒"
exit ;