自己瞎写的脚本，百度+谷歌鼓捣出来的能用就行，毕竟不是专业的。。。。。

测试环境centos7，生产环境为openwrt23.05.2原版

运行结果log在log.txt文件，请自行查看

感谢https://t.me/cf_push

每隔30分钟测试一下www.google.com能否访问，否则运行优选脚本，根据优选结果自动更改passwall节点IP、dnspod托管域名IP为优选后的IP，发送企业微信或者telegrambot通知

默认为企业微信通知，如用telegram通知请修改74行和210行将#删除

请安装jq、wget、curl、unzip

自动下载"http://zip.cm.edu.kg/"的SG.txt可以自定义

txtfile=SG.txt


建立目录/root/youxuan，把所有文件下载到这个目录里
mkdir /root/youxuan
别忘了+X权限

start.sh #加入计划任务30分钟执行一次
 */30 * * * * sh /root/youxuan/start.sh >>/root/youxuan/log.txt


修改/root/youxuan/config.sh
找到以下配置根据自己的修改

#####################################################################################################
#TG推送设置
#TG机器人token 例如：123456789:ABCDEFG...
telegramBotToken=123456789:ABCDEFG
#用户ID或频道、群ID 例如：123456789
telegramBotUserId=123456789
#####################################################################################################
#企业微信推送设置
#替换 YOUR_WEBHOOK_URL 为机器人的实际 Webhook 地址

WEBHOOK_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=x-x-x-x-x"

#####################################################################################################
#DnsPod域名更新配置
#生成的loginToken填入此处

login_token="x,x"

#域名

domain="x.x.x"

#子域名，如果是主域名，将其设置为 "@"

sub_domain="edtunnel"

#解析类型，A为ipv4,AAAA为ipv6

record_type="A"
#####################################################################################################

#定义passwall节点名称

passwallnode=kBPfeRx8

#定义passwall进程

CLIEN=passwall
#####################################################################################################


passwall打开http和socks5代理用于www.google.com检测
![image](https://github.com/jian86/openwrt_auto_cf_dnspod_passwall/assets/59141844/3911654e-4806-4f4e-95e4-5fc3c91b1bd4)

