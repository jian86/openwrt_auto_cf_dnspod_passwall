#!/bin/bash
source /root/youxuan/config.sh
#####################################################################################################
start=`date +%s`
#####################################################################################################
current_time=$(date "+%Y-%m-%d %H:%M:%S")
echo "开始时间$current_time"
sleep 10s;
#####################################################################################################
#开始通知
#####################################################################################################
#企业微信构建消息内容，包含变量
MESSAGE_CONTENT_START="{\"msgtype\": \"text\", \"text\": {\"content\": \"EDtunnel优选通知:\nwww.google.com\n检测连续10次失败\n开始优选\n$current_time\"}}" >/dev/null
#企业微信发送消息
curl -s -H "Content-Type: application/json" -X POST -d "$MESSAGE_CONTENT_START" $WEBHOOK_URL >/dev/null
#####################################################################################################
#TG构建消息内容，包含变量
message_start="EDtunnel优选开始：%0A开始时间$current_time"
#TG发送消息
#curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d chat_id=${telegramBotUserId}  -d parse_mode='HTML' -d text="$message_start" >/dev/null
#####################################################################################################
#passwall服务停止
echo "开始停止$CLIEN";
	/etc/init.d/$CLIEN stop;
echo "已停止$CLIEN";
#####################################################################################################
#优选开始

echo "开始优选IPv4"

#####################################################################################################
#下载最新IP段
while [ $retries -lt $max_retries ]; do
    retries=$((retries + 1))
    echo "正在进行第 $retries 次尝试下载最新IP段，请稍后..."
    # 下载压缩文件
    wget -qO "${DATA_DIR}txt.zip" "https://zip.baipiao.eu.org"
    
    if [ $? -eq 0 ]; then
        echo "正在解压缩最新IP段，请稍后..."
        # 解压缩文件并获取特定文件名
        file=$(unzip -l "${DATA_DIR}txt.zip" | grep "${txtfile}" | awk '{print $4}')
        
        # 解压缩特定文件
        unzip -p "${DATA_DIR}txt.zip" "$file" > "${DATA_DIR}$CFST_f"
        
        # 删除临时文件
        rm "${DATA_DIR}txt.zip"
        echo "最新IP段，获取完成..."
        break  # 如果成功获取文件，则跳出循环
    else
        echo "下载失败，正在尝试重新下载..."
    fi
done

if [ $retries -eq $max_retries ]; then
    echo "已达到最大重试次数，无法获取文件。"
fi
# sleep 3s;
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#开始测速
$DATA_DIR/CloudflareST -url $CFST_URL -tp $CFST_port -tl $CFST_tl -tll $CFST_tll -sl $CFST_sl -dn $CFST_dn -p $CFST_p -f $DATA_DIR$CFST_f -o $DATA_DIR$CFST_o
echo "测速完毕"
echo "正在更新，请稍后..."
echo "获取优选后的ip地址"
ipAddr=$(sed -n "$((x + 2)),1p" ${DATA_DIR}result.csv | awk -F, '{print $1}')
speedtest=$(sed -n "$((x + 2)),1p" ${DATA_DIR}result.csv | awk -F, '{print $6}')
speedping=$(sed -n "$((x + 2)),1p" ${DATA_DIR}result.csv | awk -F, '{print $5}')
speedloss=$(sed -n "$((x + 2)),1p" ${DATA_DIR}result.csv | awk -F, '{print $4}')
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#获取优选IP地址的国家信息
while true; do
    # 使用curl获取IP地址信息
    json=$(curl -s http://ip-api.com/json/$ipAddr?lang=zh-CN)
    
    # 检查json是否为空
    if [ -z "$json" ]; then
    #    echo "JSON为空，继续循环"
        continue
    fi

    # 提取国家信息
    country=$(echo "$json" | jq -r '.country')

    # 如果成功提取国家信息，跳出循环
    if [ ! -z "$country" ]; then
        break
    fi
done

#####################################################################################################

echo "优选的IP为$ipAddr丢包率$speedloss(%)平均延迟$speedping(ms)下载速度$speedtest(MB/s)IP区域为$country"
#####################################################################################################
#开始更新
echo 更新EDtunnel域名地址为$ipAddr
# 获取域名的 domain_id
domain_info=$(curl -s -X POST https://dnsapi.cn/Domain.Info -d "login_token=${login_token}&format=json&domain=${domain}")
domain_id=$(echo "${domain_info}" | awk -F'"id"' '{print $2}' | awk -F'"' '{print $2}')

# 获取子域名的 record_id
record_info=$(curl -s -X POST https://dnsapi.cn/Record.List -d "login_token=${login_token}&format=json&domain_id=${domain_id}&sub_domain=${sub_domain}")
record_id=$(echo "${record_info}" | awk -F'"records"' '{print $2}' | awk -F'"id"' '{print $2}' | awk -F'"' '{print $2}')

curl -s -X POST https://dnsapi.cn/Record.Modify -d "login_token=$login_token&format=json&domain_id=$domain_id&record_id=$record_id&record_type=A&record_line=默认&sub_domain=$sub_domain&value=$ipAddr" >/dev/null
sleep 3s;
ip_addr_dns=`curl -s https://dnsapi.cn/Record.Info -d "login_token=${login_token}&format=json&domain_id=${domain_id}&record_id=${record_id}&remark="|awk -F '"value"' '{print $2}'|awk -F "\"" '{print $2}'`; >/dev/null
echo 验证EDtunnel域名地址为$ip_addr_dns
#sleep 3s;
#####################################################################################################
#开始重启
/etc/init.d/$CLIEN restart;
echo "已重启$CLIEN";
sleep 3s;
#开始更新
uci set passwall.${passwallnode}.address=$ipAddr
uci commit passwall
sleep 10s;
#####################################################################################################
# #再次重启
# /etc/init.d/$CLIEN restart;
# echo "已再次重启$CLIEN";
#####################################################################################################
#echo "EDtunnel域名IP设置为$ip_addr_dns"
#sleep 3s;
#####################################################################################################
#定义passwall节点设置IP
ip=$(uci show passwall.${passwallnode}.address)
substring=${ip:26}
#echo "PassWall节点IP设置为$substring"
#####################################################################################################
#执行时长
end=`date +%s.%N`
runtime=$(echo "$end - $start" | bc -l)
#停止时间
shutdown_time=$(date "+%Y-%m-%d %H:%M:%S")
#####################################################################################################
#结束通知
#####################################################################################################
#企业微信构建消息内容，包含变量
MESSAGE_CONTENT="{\"msgtype\": \"text\", \"text\": {\"content\": \"EDtunnel优选通知:\n开始时间$current_time\nEDtunnel域名设置为'$ip_addr_dns'\nPassWall节点设置为$substring\n丢包率$speedloss(%)\n平均延迟$speedping(ms)\n下载速度$speedtest(MB/s)\nIP区域为$country\n结束时间$shutdown_time\n执行时长$runtime秒\"}}"
#企业微信发送消息
curl -s -H "Content-Type: application/json" -X POST -d "$MESSAGE_CONTENT" $WEBHOOK_URL >/dev/null
#####################################################################################################
#TG构建消息内容，包含变量
message="EDtunnel优选通知:%0A开始时间$current_time%0AEDtunnel域名设置为'$ip_addr_dns'%0APassWall节点设置为$substring%0A丢包率$speedloss(%)%0A平均延迟$speedping(ms)%0A下载速度$speedtest(MB/s)%0AIP区域为$country%0A结束时间$shutdown_time%0A执行时长$runtime秒"
#TG发送消息
#curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d chat_id=${telegramBotUserId}  -d parse_mode='HTML' -d text="$message" >/dev/null
#####################################################################################################
echo "结束时间$shutdown_time"
echo "执行时长$runtime秒"


#####################################################################################################
#通知内容演示
echo "#####################################################################################################"
echo "#####################################################################################################"
echo "#####################################################################################################"
echo "EDtunnel优选通知:"
echo "开始时间${current_time}"
echo "EDtunnel域名设置为'${ip_addr_dns}'"
echo "PassWall节点设置为${substring}"
echo "丢包率${speedloss}(%)"
echo "平均延迟${speedping}(ms)"
echo "下载速度${speedtest}(MB/s)"
echo "IP区域为${country}"
echo "结束时间${shutdown_time}"
echo "执行时长${runtime}秒"
echo "#####################################################################################################"
echo "#####################################################################################################"
echo "#####################################################################################################"
echo "#####################################################################################################"
#####################################################################################################
exit ;