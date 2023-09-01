#!/bin/bash
export LANG=zh_CN.UTF-8
auth_email="xxxx@gmail.com"    #你的CloudFlare注册账户邮箱 *必填
auth_key="xxxxxxxxxxxxxxx"   #你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。*必填
zone_name="xxxx.com"     #你的主域名 *必填

record_name="hk"    #自动更新的二级域名前缀,必须取hk sg kr jp us等常用国家代码
record_count=4 #二级域名个数，例如配置4个，则域名分别是hk1、hk2、hk3、hk4.   后面的信息均不需要修改，让他自动运行就好了。
port=443 #自定义测速端口
speedurl="https://vipcs.cloudflarest.link" #自定义测速地址，可以参考@科技KKK视频制作自己专属的测速链接，避免拥挤造成的测速不准。https://www.youtube.com/watch?v=AhJbfNdU0PE&t=439s

proxygithub="https://ghproxy.com/" #反代github加速地址，如果不需要可以将引号内容删除，如需修改请确保/结尾 例如"https://ghproxy.com/"

update_gengxinzhi=0
update_gengxin() {
    if [ "$update_gengxinzhi" -eq 0 ]; then
        sudo apt update
        update_gengxinzhi=$((update_gengxinzhi + 1))
    fi
}

# 检测是否已经安装了Git和Curl
if ! command -v git &> /dev/null; then
    echo "Git 未安装，开始安装..."
	update_gengxin
    sudo apt install git -y
    echo "Git 安装完成！"
else
    echo "Git 已安装."
fi

if ! command -v curl &> /dev/null; then
    echo "Curl 未安装，开始安装..."
	update_gengxin
    sudo apt install curl -y
    echo "Curl 安装完成！"
else
    echo "Curl 已安装."
fi

if ! command -v awk &> /dev/null; then
    echo "awk 未安装，开始安装..."
	update_gengxin
    sudo apt install awk -y
    echo "awk 安装完成！"
else
    echo "awk 已安装."
fi

# 更新geoiplookup IP库
download_GeoLite_mmdb() {
	# 发送 API 请求获取仓库信息（替换 <username> 和 <repo>）
	geoiplookup_latest_version=$(curl -s https://api.github.com/repos/P3TERX/GeoLite.mmdb/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
	echo "最新版本号: $geoiplookup_latest_version"
	# 下载文件到当前目录
	curl -L -o /usr/share/GeoIP/GeoLite2-Country.mmdb "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/releases/download/$geoiplookup_latest_version/GeoLite2-Country.mmdb"
}

# 检测是否已经安装了geoiplookup
if ! command -v geoiplookup &> /dev/null; then
    echo "geoiplookup 未安装，开始安装..."
    update_gengxin
    sudo apt install geoip-bin -y
    echo "geoiplookup 安装完成！"
	echo "GeoLite.mmdb 开始更新..."
	download_GeoLite_mmdb
	echo "GeoLite.mmdb 更新完成！"
else
    echo "geoiplookup 已安装."
fi

# 检测GeoLite2-Country.mmdb文件是否存在
if [ ! -f "/usr/share/GeoIP/GeoLite2-Country.mmdb" ]; then
    echo "文件 /usr/share/GeoIP/GeoLite2-Country.mmdb 不存在。正在下载..."
    
    # 使用curl命令下载文件
    curl -L -o /usr/share/GeoIP/GeoLite2-Country.mmdb "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb"
    
    # 检查下载是否成功
    if [ $? -eq 0 ]; then
        echo "下载完成。"
    else
        echo "下载失败。脚本终止。"
        exit 1
    fi
fi

# 检测是否已经安装了mmdb-bin
if ! command -v mmdblookup &> /dev/null; then
    echo "mmdblookup 未安装，开始安装..."
    update_gengxin
    sudo apt install mmdb-bin -y
    echo "mmdblookup 安装完成！"
else
    echo "mmdblookup 已安装."
fi

download_CloudflareST() {
    # 发送 API 请求获取仓库信息（替换 <username> 和 <repo>）
    latest_version=$(curl -s https://api.github.com/repos/XIU2/CloudflareSpeedTest/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "最新版本号: $latest_version"
    # 下载文件到当前目录
    curl -L -o CloudflareST_linux_amd64.tar.gz "${proxygithub}https://github.com/XIU2/CloudflareSpeedTest/releases/download/$latest_version/CloudflareST_linux_amd64.tar.gz"
    # 解压CloudflareST文件到当前目录
    sudo tar -xvf CloudflareST_linux_amd64.tar.gz CloudflareST -C /
	rm CloudflareST_linux_amd64.tar.gz

}

# 尝试次数
max_attempts=5
current_attempt=1

while [ $current_attempt -le $max_attempts ]; do
    # 检查是否存在CloudflareST文件
    if [ -f "CloudflareST" ]; then
        echo "CloudflareST 准备就绪。"
        break
    else
        echo "CloudflareST 未准备就绪。"
        echo "第 $current_attempt 次下载 CloudflareST ..."
        download_CloudflareST
    fi

    ((current_attempt++))
done

if [ $current_attempt -gt $max_attempts ]; then
    echo "连续 $max_attempts 次下载失败。请检查网络环境时候可以访问github后重试。"
    exit 1
fi

upip(){
# 检测temp文件夹是否存在
if [ -d "temp" ]; then
    echo "开始清理IP临时文件..."
    rm -r temp/*
    echo "清理IP临时文件完成。"
else
    echo "创建IP临时文件。"
	mkdir -p temp
fi

# 下载txt.zip文件并另存为txt.zip
curl -Lo txt.zip https://zip.baipiao.eu.org
# 解压磅.zip到temp文件夹
unzip -o txt.zip -d temp/
# 删除下载的zip文件
rm txt.zip
echo "baipiao.eu.org IP库下载完成。"

echo "验证更新hello-earth IP库"
git clone "${proxygithub}https://github.com/hello-earth/cloudflare-better-ip.git"

# 检查cloudflare-better-ip/cloudflare内是否有文件
if [ -d "cloudflare-better-ip/cloudflare" ] && [ -n "$(ls -A cloudflare-better-ip/cloudflare)" ]; then
    echo "正在更新hello-earth IP库"
    # 复制cloudflare-better-ip/cloudflare内的文件到temp文件夹
	cat cloudflare-better-ip/cloudflare/*.txt > cloudflare-better-ip/cloudflare-ip.txt
	awk -F ":443" '{print $1}' cloudflare-better-ip/cloudflare-ip.txt > temp/hello-earth-ip.txt
    echo "hello-earth IP库下载完成。"

    # 删除cloudflare-better-ip文件夹
    rm -r cloudflare-better-ip
    # echo "cloudflare-better-ip文件夹已删除。"
else
    echo "hello-earth IP库 无更新内容"
fi

echo "验证更新cmliu IP库"
git clone "${proxygithub}https://github.com/cmliu/cloudflare-better-ip.git"

# 检查cmliu/cloudflare-better-ip/cloudflare内是否有文件
if [ -d "cloudflare-better-ip" ] && [ -n "$(ls -A cloudflare-better-ip)" ]; then
    echo "正在更新cmliu IP库"
    # 复制cloudflare-better-ip内的文件到temp文件夹
	cp -r cloudflare-better-ip/*.txt temp/
    echo "cmliu IP库下载完成。"

    # 删除cloudflare-better-ip文件夹
    rm -r cloudflare-better-ip
    # echo "cloudflare-better-ip文件夹已删除。"
else
    echo "cmliu IP库 无更新内容"
fi

cat temp/*.txt > ip_temp.txt
# 检查ip.txt文件是否存在
if [ -f "ip.txt" ]; then
    rm ip.txt
    echo "清除旧的ip库"
fi
awk '!a[$0]++' ip_temp.txt > ip.txt
rm ip_temp.txt
echo "去重合并整理IP库完成"

# 检查ip.txt文件是否存在
if [ -f "ip.txt" ]; then

	# 检测ip文件夹是否存在
	if [ -d "ip" ]; then
		echo "开始清理IP地区文件"
		rm -r "ip"/*
		echo "清理IP地区文件完成。"
	else
		echo "创建IP地区文件。"
		mkdir -p ip
	fi

echo "正在将IP按国家代码保存到ip文件夹内..."
    # 逐行处理ip.txt文件
    while read -r line; do
        ip=$(echo $line | cut -d ' ' -f 1)  # 提取IP地址部分
		
        #country_code=$(geoiplookup $ip | awk -F ', ' '{print $1}')  # 获取国家代码
		
		#mmdblookup --file /usr/share/GeoIP/GeoLite2-Country.mmdb  --ip 8.8.8.8 country iso_code
		result=$(mmdblookup --file /usr/share/GeoIP/GeoLite2-Country.mmdb --ip $ip country iso_code)
		country_code=$(echo $result | awk -F '"' '{print $2}')
		echo $ip >> "ip/${country_code}.txt"  # 写入对应的国家文件
    done < ip.txt

    echo "IP已按国家分类保存到ip文件夹内。"
else
    echo "ip.txt文件不存在，脚本终止。"
    exit 1
fi
}

# 检查ip.txt文件是否存在
if [ -e "ip.txt" ]; then
    # 获取ip.txt文件的最后编辑时间戳
    file_timestamp=$(stat -c %Y ip.txt)

    # 获取当前时间戳
    current_timestamp=$(date +%s)

    # 计算时间差（以秒为单位）
    time_diff=$((current_timestamp - file_timestamp))

    # 将6小时转换为秒
    eight_hours_in_seconds=$((6 * 3600))

    # 如果时间差小于6小时
    if [ "$time_diff" -lt "$eight_hours_in_seconds" ]; then
        # 继续执行后续脚本逻辑
        echo "ip.txt文件已是最新版本，无需更新"
    else
        echo "ip.txt文件已过期，开始更新整合IP库"
	upip
    fi
else
    echo "ip.txt文件不存在，开始更新整合IP库"
    upip
fi

if [ ! -d "log" ]; then
  mkdir log
fi

#带有地区参数，将赋值第1参数为地区
if [ -n "$1" ]; then 
    record_name="$1"
    echo "地区 $1"
fi

#带有二级域名个数参数，将赋值第2参数为端口
if [ -n "$2" ]; then
    record_count="$2"
    echo "获取域名数量 $2"
fi
speedqueue=$((record_count * 32)) #自定义测速队列，默认设置为配置域名数的16倍

#带有域名参数，将赋值第3参数为地区
if [ -n "$3" ]; then 
    zone_name="$3"
    echo "域名 $3"
fi

#带有端口参数，将赋值第4参数为端口
if [ -n "$4" ]; then
    port="$4"
    echo "测速端口 $4"
fi

#带有自定义测速地址参数，将赋值第5参数为自定义测速地址
if [ -n "$5" ]; then
    speedurl="$5"
    echo "自定义测速地址 $5"
else
    echo "使用默认测速地址 $speedurl"
fi

record_name0="${record_name^^}"
ip_txt="ip/${record_name0}.txt"
result_csv="log/${record_name0}.csv"

if [ ! -f "$ip_txt" ]; then
    echo "$record_name0 地区IP文件 $ip_txt 不存在。脚本终止。"
    exit 1
fi

echo "$record_name0 地区IP文件 $ip_txt 存在"
echo "待处理域名 ${record_name}[1-${record_count}].${zone_name}:${port}"
echo '你的IP地址是'$(curl 4.ipw.cn)',请确认为本机未经过代理的地址'

#./CloudflareST -tp 443 -url "https://cs.cmliussss.link" -f "ip/HK.txt" -dn 128 -tl 260 -p 10 -o "log/HK.csv"
./CloudflareST -tp $port -url $speedurl -f $ip_txt -dn $speedqueue -tl 280 -p $record_count -o $result_csv

record_type="A"     
#获取zone_id、record_id
zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
#echo $zone_identifier

sed -n '2,20p' $result_csv | while read line
do
    #echo $record_name$record_count'.'$zone_name
    record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name$record_count"'.'"$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
    #echo $record_identifier
    #更新DNS记录
    update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" --data "{\"type\":\"$record_type\",\"name\":\"$record_name$record_count.$zone_name\",\"content\":\"${line%%,*}\",\"ttl\":60,\"proxied\":false}")
    #反馈更新情况
    if [[ "$update" != "${update%success*}" ]] && [[ "$(echo $update | grep "\"success\":true")" != "" ]]; then
      echo $record_name$record_count'.'$zone_name'更新为:'${line%%,*}'....成功'
    else
      echo $record_name$record_count'.'$zone_name'更新失败:'$update
    fi

    record_count=$(($record_count-1))    #二级域名序号递减
    echo $record_count
    if [ $record_count -eq 0 ]; then
        break
    fi

done
