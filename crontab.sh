#!/bin/bash

# 设置测试用的代理服务器地址和端口
proxy_server="127.0.0.1:1081"
test_website="www.google.com"



# 设置测试次数上限
max_retries=10
retry_count=0

# 循环测试代理服务器是否能访问指定网站
while [ $retry_count -lt $max_retries ]; do
    if curl -x socks5h://$proxy_server -s --head -m 1 $test_website | head -n 1 | grep "200 OK" > /dev/null; then
	current_time1=$(date "+%Y-%m-%d %H:%M:%S")
	echo "#####################################################################################################"
        echo "$current_time1 代理服务器 $proxy_server 可以访问 $test_website."
        exit 0
    else
	current_time2=$(date "+%Y-%m-%d %H:%M:%S")
	echo "#####################################################################################################"
        echo "$current_time2 代理服务器 $proxy_server 不能访问 $test_website. 尝试次数: $((retry_count + 1))"
        retry_count=$((retry_count + 1))
        sleep 1  # 暂停1秒后再次测试
    fi
done

# 达到最大尝试次数后执行执行Edtunnel脚本脚本
current_time3=$(date "+%Y-%m-%d %H:%M:%S")
echo "#####################################################################################################"
echo "$current_time3 连续 $max_retries 次无法访问 $test_website，执行Edtunnel脚本..."
sh /root/youxuan/edtunnel.sh