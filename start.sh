#!/bin/bash
source /root/youxuan/config.sh
current_time=$(date "+%Y-%m-%d %H:%M:%S")
if ps | grep -v grep | grep "CloudflareST" >/dev/null; then
#企业微信构建消息内容，包含变量
MESSAGE_CONTENT_START="{\"msgtype\": \"text\", \"text\": {\"content\": \"EDtunnel优选通知:\n优选进程正在执行，退出计划任务！\n$current_time\"}}" >/dev/null
#企业微信发送消息
curl -s -H "Content-Type: application/json" -X POST -d "$MESSAGE_CONTENT_START" $WEBHOOK_URL >/dev/null
#TG构建消息内容，包含变量
message_start="EDtunnel优选开始：%0A优选进程正在执行，退出计划任务！%0A$current_time"
#TG发送消息
#curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d chat_id=${telegramBotUserId}  -d parse_mode='HTML' -d text="$message_start" >/dev/null
    echo "CloudflareST 进程正在执行！"
	exit 0
else
    # 运行 crontab.sh 脚本
    $DATA_DIR/crontab.sh
fi


