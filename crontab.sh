#!/bin/bash
source /root/youxuan/config.sh

# 循环测试代理服务器是否能访问指定网站
while [ $url_retry_count -lt $url_max_retries ]; do
    if curl -x socks5h://$proxy_server -s --head -m 1 $url_website | head -n 1 | grep "200 OK" > /dev/null; then
	current_time1=$(date "+%Y-%m-%d %H:%M:%S")
	echo "#####################################################################################################"
        echo "$current_time1 代理服务器 $proxy_server 可以访问 $url_website."
        exit 0
    else
	current_time2=$(date "+%Y-%m-%d %H:%M:%S")
	echo "#####################################################################################################"
        echo "$current_time2 代理服务器 $proxy_server 不能访问 $url_website. 尝试次数: $((url_retry_count + 1))"
        url_retry_count=$((url_retry_count + 1))
        sleep 1  # 暂停1秒后再次测试
    fi
done

# 达到最大尝试次数后执行执行Edtunnel脚本脚本
current_time3=$(date "+%Y-%m-%d %H:%M:%S")
echo "#####################################################################################################"
echo "$current_time3 连续 $url_max_retries 次无法访问 $url_website，执行Edtunnel脚本..."
#运行edtunnel.sh脚本
sh $DATA_DIR/edtunnel.sh