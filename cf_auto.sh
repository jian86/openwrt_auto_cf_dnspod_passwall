#!/bin/bash
patch=/root/youxuan/
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
CFST_URL=https://speed.cloudflare.com/__down?bytes=200000000
#指定测速端口；延迟测速/下载测速时使用的端口；(默认 443 端口)
CFST_port=443
#平均延迟上限；只输出低于指定平均延迟的 IP，各上下限条件可搭配使用；(默认 9999 ms)
CFST_tl=200
#平均延迟下限；只输出高于指定平均延迟的 IP；(默认 0 ms)
CFST_tll=40
#下载速度下限；只输出高于指定下载速度的 IP，凑够指定数量 [-dn] 才会停止测速；(默认 0.00 MB/s)
CFST_sl=5
#下载测速数量；延迟测速并排序后，从最低延迟起下载测速的数量；(默认 10 个)
CFST_dn=20
#显示结果数量；测速后直接显示指定数量的结果，为 0 时不显示结果直接退出；(默认 10 个)
CFST_p=20
#IP段数据文件；如路径含有空格请加上引号；支持其他 CDN IP段；(默认 ip.txt)
CFST_f=ip.txt
#####################################################################################################
start=`date +%s`
#####################################################################################################
#passwall
# echo "开始停止$CLIEN";
	# /etc/init.d/$CLIEN stop;
# echo "已停止$CLIEN";
#####################################################################################################
#优选开始
current_time=$(date "+%Y-%m-%d %H:%M:%S")
echo "开始时间$current_time"
echo "开始优选IPv4"
#####################################################################################################
echo "正在下载最新IP段，请稍后..."
# 下载压缩文件
wget -qO txt.zip https://zip.baipiao.eu.org
echo "正在解压缩最新IP段，请稍后..."
# 解压缩文件并获取特定文件名
file=$(unzip -l txt.zip | grep '31898-.*-443.txt' | awk '{print $4}')
# 解压缩特定文件
unzip -p txt.zip "$file" > ip.txt
# 删除临时文件
rm txt.zip
echo "最新IP段，获取完成..."
sleep 3s;
#####################################################################################################
#开始测速
$patch/CloudflareST -url $CFST_URL -tp $CFST_port -tl $CFST_tl -tll $CFST_tll -sl $CFST_sl -dn $CFST_dn -p $CFST_p -f $patch$CFST_f
echo "测速完毕"
echo "正在更新，请稍后..."
echo "获取优选后的ip地址"
ipAddr=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $1}')
speedtest=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $6}')
speedping=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $5}')
speedloss=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $4}')
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
#####################################################################################################
#定义passwall节点设置IP
ip=$(uci show passwall.${passwallnode}.address)
substring=${ip:26}
echo "passwall节点IP设置为$substring"
#####################################################################################################
end=`date +%s.%N`
runtime=$(echo "$end - $start" | bc -l)
#停止时间
shutdown_time=$(date "+%Y-%m-%d %H:%M:%S")
#####################################################################################################
#开始通知
message="EDtunnel优选通知：%0A开始时间$current_time%0AEDtunnel域名优选为'$ip_addr_dns'%0Apasswall节点设置为$substring%0A丢包率$speedloss(%)%0A平均延迟$speedping(ms)%0A下载速度$speedtest(MB/s)%0A结束时间$shutdown_time%0A执行时长$runtime秒"
curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d chat_id=${telegramBotUserId}  -d parse_mode='HTML' -d text="$message"
#####################################################################################################
echo "结束时间$shutdown_time"
echo "执行时长$runtime秒"
#####################################################################################################
exit ;