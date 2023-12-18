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
ipAddr=104.26.1.135

curl -s -X POST https://dnsapi.cn/Record.Modify -d "login_token=$login_token&format=json&domain_id=$domain_id&record_id=$record_id&record_type=A&record_line=默认&sub_domain=$sub_domain&value=$ipAddr" | jq '.result.text'
ip_addr_dns=`curl -s https://dnsapi.cn/Record.Info -d "login_token=${login_token}&format=json&domain_id=${domain_id}&record_id=${record_id}&remark="|awk -F '"value"' '{print $2}'|awk -F "\"" '{print $2}'`;
echo $ip_addr_dns

