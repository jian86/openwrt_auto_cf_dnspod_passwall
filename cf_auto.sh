#!/bin/bash
##版本：V2.1.1
	#新功能，支持更新优选完毕后推送至TG，再也不怕脚本没有成功运行了。
	#使用脚本需要安装jq和timeout，新增openwrt专用cf_RE.sh文件，运行cf_RE.sh即可在openwrt安装jq和timeout两个扩展。
	#其他linux请自行安装jq和timeout。
	
###################################################################################################
##运行模式ipv4 or ipv6 默认为：ipv4
#指定工作模式为ipv4还是ipv6。如果为ipv6，请在文件夹下添加ipv6.txt
#ipv6.txt在CloudflareST工具包里，下载地址：https://github.com/XIU2/CloudflareSpeedTest/releases
IP_ADDR=ipv4
###################################################################################################
##openwrt科学上网插件配置
#优选节点时是否自动停止科学上网服务 true=自动停止 false=不停止 默认为 true
pause=true
#填写openwrt使用的是哪个科学上网客户端，填写对应的“数字”  默认为 1  客户端为passwall
# 1=passwall 2=passwall2 3=ShadowSocksR Plus+ 4=clash 5=openclash 6=bypass
clien=1
###################################################################################################
##CloudflareST配置
#测速地址  
CFST_URL=https://speed.cloudflare.com/__down?bytes=200000000
#测速线程数量；越多测速越快，性能弱的设备 (如路由器) 请勿太高；(默认 200 最多 1000 )
CFST_N=200
#延迟测速次数；单个 IP 延迟测速次数，为 1 时将过滤丢包的IP，TCP协议；(默认 4 次 )
CFST_T=1
#下载测速数量；延迟测速并排序后，从最低延迟起下载测速的数量；(默认 10 个)
CFST_DN=10
#平均延迟上限；只输出低于指定平均延迟的 IP，可与其他上限/下限搭配；(默认9999 ms 这里推荐配置250 ms)
CFST_TL=250
#平均延迟下限；只输出高于指定平均延迟的 IP，可与其他上限/下限搭配、过滤假墙 IP；(默认 0 ms 这里推荐配置40)
CFST_TLL=40
#下载速度下限；只输出高于指定下载速度的 IP，凑够指定数量 [-dn] 才会停止测速；(默认 0.00 MB/s 这里推荐5.00MB/s)
CFST_SL=5
#####################################################################################################
##TG推送设置
#（填写即为开启推送，未填写则为不开启）
#TG机器人token 例如：123456789:ABCDEFG...
telegramBotToken=912320458:AAH_mSzRYfy13eDxvWsRwurA9p2x30EzhrU
#用户ID或频道、群ID 例如：123456789
telegramBotUserId=-4093558163
#####################################################################################################


ipv4Regex="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])";
#默认关闭小云朵
proxy="false";

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

#判断工作模式
if [ "$IP_ADDR" = "ipv6" ] ; then
    if [ ! -f "ipv6.txt" ]; then
        echo "当前工作模式为ipv6，但该目录下没有【ipv6.txt】，请配置【ipv6.txt】。下载地址：https://github.com/XIU2/CloudflareSpeedTest/releases";
        exit 2;
        else
            echo "当前工作模式为ipv6";
    fi
    else
        echo "当前工作模式为ipv4";
fi

#读取配置文件中的客户端
if  [ "$clien" = "6" ] ; then
	CLIEN=bypass;
elif  [ "$clien" = "5" ] ; then
		CLIEN=openclash;
elif  [ "$clien" = "4" ] ; then
	CLIEN=clash;
elif  [ "$clien" = "3" ] ; then
		CLIEN=shadowsocksr;
elif  [ "$clien" = "2" ] ; then
			CLIEN=passwall2;
			else
			CLIEN=passwall;
fi

#判断是否停止科学上网服务
if [ "$pause" = "false" ] ; then
	echo "按要求未停止科学上网服务";
else
	/etc/init.d/$CLIEN stop;
	echo "已停止$CLIEN";
fi

#判断是否配置测速地址 
if [[ "$CFST_URL" == http* ]] ; then
	CFST_URL_R="-url $CFST_URL";
else
	CFST_URL_R="";
fi


if [ "$IP_ADDR" = "ipv6" ] ; then
    #开始优选IPv6
    ./CloudflareST -url $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -p $CFST_P -f ipv6.txt
    else
    #开始优选IPv4
    /root/youxuan/CloudflareST -url https://speed.cloudflare.com/__down?bytes=200000000 -tl 200 -tll 40 -sl 5 -f /root/youxuan/ip.txt
fi
echo "测速完毕";
if [ "$pause" = "false" ] ; then
		echo "按要求未重启科学上网服务";
		sleep 3s;
else
		/etc/init.d/$CLIEN restart;
		echo "已重启$CLIEN";
		echo "为保证连接正常 将在3秒后开始更新";
		sleep 3s;
fi
#开始循环
echo "正在更新，请稍后...";
    #获取优选后的ip地址
    ipAddr=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $1}');
    echo "开始更新第$((x + 1))个---$ipAddr";
    #开始更新
uci set passwall.Zu7EWzqN.address=$ipAddr
uci commit passwall
uci show passwall.Zu7EWzqN.address
		/etc/init.d/$CLIEN restart;
echo "已重启$CLIEN";
echo "正在更新DNSPOD，请稍后...";

clear
curl https://dnsapi.cn/Record.Modify -d "login_token=$login_token&format=json&domain_id=$domain_id&record_id=$record_id&record_type=A&record_line=默认&sub_domain=$sub_domain&value=$ipAddr"
    sleep 3s;
	
clear
#curl -s -X POST https://api.telegram.org/bot912320458:AAH_mSzRYfy13eDxvWsRwurA9p2x30EzhrU/sendMessage -d chat_id=-4093558163  -d parse_mode='HTML' -d text="EDtunnel优选为$ipAddr"
curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d chat_id=${telegramBotUserId}  -d parse_mode='HTML' -d text="EDtunnel优选为$ipAddr"

clear

passip=$(uci show passwall.Zu7EWzqN.address)
echo 优选IP设置为${passip:27:13}
exit ;
