#!/bin/bash
# $ ./speed.sh hk 443 4 xxxx.com xxxx@gmail.com xxxxxxxxxxxxxxx https://vipcs.cloudflarest.link
export LANG=zh_CN.UTF-8
auth_email="xxxx@gmail.com"    #你的CloudFlare注册账户邮箱 *必填
auth_key="xxxxxxxxxxxxxxx"   #你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。*必填
zone_name="xxxx.com"     #你的主域名 *必填

area_GEC="hk"    #自动更新的二级域名前缀,必须取hk sg kr jp us等常用国家代码
port=443 #自定义测速端口 不能为空!!!
record_count=4 #二级域名个数，例如配置4个，则域名分别是 hk-443-1.xxxx.com 、hk-443-2.xxxx.com 、hk-443-3.xxxx.com 、hk-443-4.xxxx.com

speedtestMB=90 #测速文件大小 单位MB，文件过大会拖延测试时长，过小会无法测出准确速度
speedlower=10  #自定义下载速度下限,单位为mb/s
lossmax=0.75  #自定义丢包几率上限；只输出低于/等于指定丢包率的 IP，范围 0.00~1.00，0 过滤掉任何丢包的 IP
speedqueue_max=1 #自定义测速IP冗余量
###############################################################以下脚本内容，勿动#######################################################################
speedurl="https://speed.cloudflare.com/__down?bytes=$((speedtestMB * 1000000))" #官方测速链接
proxygithub="https://ghproxy.com/" #反代github加速地址，如果不需要可以将引号内容删除，如需修改请确保/结尾 例如"https://ghproxy.com/"

#带有地区参数，将赋值第1参数为地区
if [ -n "$1" ]; then 
    area_GEC="$1"
fi

#带有端口参数，将赋值第2参数为端口
if [ -n "$2" ]; then
    port="$2"
fi

#带有CloudFlare账户邮箱参数，将赋值第5参数
if [ -n "$5" ]; then
    auth_email="$5"
fi

#带有CloudFlare账户key参数，将赋值第6参数
if [ -n "$6" ]; then
    auth_key="$6"
fi

# 选择客户端 CPU 架构
archAffix(){
    case "$(uname -m)" in
        i386 | i686 ) echo '386' ;;
        x86_64 | amd64 ) echo 'amd64' ;;
        armv8 | arm64 | aarch64 ) echo 'arm64' ;;
        s390x ) echo 's390x' ;;
        * ) red "不支持的CPU架构!" && exit 1 ;;
    esac
}

update_gengxinzhi=0
apt_update() {
    if [ "$update_gengxinzhi" -eq 0 ]; then
        sudo apt update
        update_gengxinzhi=$((update_gengxinzhi + 1))
    fi
}

# 检测并安装软件函数
apt_install() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 未安装，开始安装..."
        apt_update
        sudo apt install "$1" -y
        echo "$1 安装完成！"
    fi
}

# 检测并安装 Git、Curl、unzip 和 awk
apt_install git
apt_install curl
apt_install unzip
apt_install awk
apt_install jq

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
    if [ -z "$latest_version" ]; then
    	latest_version="v2.2.4"
    	echo "下载版本号: $latest_version"
    else
    	echo "最新版本号: $latest_version"
    fi
    # 下载文件到当前目录
    curl -L -o CloudflareST.tar.gz "${proxygithub}https://github.com/XIU2/CloudflareSpeedTest/releases/download/$latest_version/CloudflareST_linux_$(archAffix).tar.gz"
    # 解压CloudflareST文件到当前目录
    sudo tar -xvf CloudflareST.tar.gz CloudflareST -C /
	rm CloudflareST.tar.gz

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
# 解压txt.zip到temp文件夹
mkdir -p temp/temp
unzip -o txt.zip -d temp/temp/
mv temp/temp/*-${port}.txt temp/
# 删除下载的zip文件
rm -r temp/temp
rm txt.zip
echo "baipiao.eu.org IP库下载完成。"

# 如果port等于443，则执行更新hello-earth IP库
if [ "$port" -eq 443 ]; then
    echo "验证更新hello-earth IP库"
    git clone "${proxygithub}https://github.com/hello-earth/cloudflare-better-ip.git"
    # 在这里添加你要执行的操作
    
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
fi

echo "验证更新cmliu IP库"
git clone "${proxygithub}https://github.com/cmliu/cloudflare-better-ip.git"

# 检查cmliu/cloudflare-better-ip/cloudflare内是否有文件
if [ -d "cloudflare-better-ip" ] && [ -n "$(ls -A cloudflare-better-ip)" ]; then
    echo "正在更新cmliu IP库"
    # 复制cloudflare-better-ip内的文件到temp文件夹
    cp -r cloudflare-better-ip/*-${port}.txt temp/
    echo "cmliu IP库下载完成。"

    # 删除cloudflare-better-ip文件夹
    rm -r cloudflare-better-ip
    # echo "cloudflare-better-ip文件夹已删除。"
else
    echo "cmliu IP库 无更新内容"
fi

if [ -e "Domain.txt" ]; then
  if [ -e "Domain2IP.py" ]; then
    python Domain2IP.py
  else
    curl -k -O "${proxygithub}https://raw.githubusercontent.com/cmliu/AutoCloudflareSpeedTest/main/Domain2IP.py"
    if [ $? -eq 0 ]; then
      python Domain2IP.py
    fi
  fi
fi

cat temp/*.txt > ip_temp.txt
# 检查ip-${port}.txt文件是否存在
if [ -f "ip-${port}.txt" ]; then
    rm ip-${port}.txt
    echo "清除旧的ip库"
fi
awk '!a[$0]++' ip_temp.txt > ip-${port}.txt
rm ip_temp.txt
echo "去重合并整理IP库完成"

# 检查ip-${port}.txt文件是否存在
if [ -f "ip-${port}.txt" ]; then

	# 检测ip文件夹是否存在
	if [ -d "ip" ]; then
		echo "开始清理IP地区文件"
		rm -r "ip"/*-${port}.txt
		echo "清理IP地区文件完成。"
	else
		echo "创建IP地区文件。"
		mkdir -p ip
	fi

echo "正在将IP按国家代码保存到ip文件夹内..."
    # 逐行处理ip-${port}.txt文件
    while read -r line; do
        ip=$(echo $line | cut -d ' ' -f 1)  # 提取IP地址部分
		
        #country_code=$(geoiplookup $ip | awk -F ', ' '{print $1}')  # 获取国家代码
		
		#mmdblookup --file /usr/share/GeoIP/GeoLite2-Country.mmdb  --ip 8.8.8.8 country iso_code
		result=$(mmdblookup --file /usr/share/GeoIP/GeoLite2-Country.mmdb --ip $ip country iso_code)
		country_code=$(echo $result | awk -F '"' '{print $2}')
		echo $ip >> "ip/${country_code}-${port}.txt"  # 写入对应的国家文件
    done < ip-${port}.txt

    echo "IP已按国家分类保存到ip文件夹内。"
else
    echo "ip-${port}.txt文件不存在，脚本终止。"
    exit 1
fi
}

# 检查ip-${port}.txt文件是否存在
if [ -e "ip-${port}.txt" ]; then
    # 获取ip-${port}.txt文件的最后编辑时间戳
    file_timestamp=$(stat -c %Y ip-${port}.txt)

    # 获取当前时间戳
    current_timestamp=$(date +%s)

    # 计算时间差（以秒为单位）
    time_diff=$((current_timestamp - file_timestamp))

    # 将6小时转换为秒
    eight_hours_in_seconds=$((6 * 3600))

    # 如果时间差小于6小时
    if [ "$time_diff" -lt "$eight_hours_in_seconds" ]; then
        # 继续执行后续脚本逻辑
        echo "ip-${port}.txt文件已是最新版本，无需更新"
    else
        echo "ip-${port}.txt文件已过期，开始更新整合IP库"
	upip
    fi
else
    echo "ip-${port}.txt文件不存在，开始更新整合IP库"
    upip
fi

if [ ! -d "log" ]; then
  mkdir log
fi

#带有二级域名个数参数，将赋值第3参数为端口
if [ -n "$3" ]; then
    record_count="$3"
    echo "获取域名数量 $3"
fi
speedqueue=$((record_count + speedqueue_max)) #自定义测速队列，多测2条做冗余

#带有域名参数，将赋值第3参数为地区
if [ -n "$4" ]; then 
    zone_name="$4"
    echo "域名 $4"
fi

#带有自定义测速地址参数，将赋值第7参数为自定义测速地址
if [ -n "$7" ]; then
    speedurl="$7"
    echo "自定义测速地址 $7"
else
    echo "使用默认测速地址 $speedurl"
fi

record_name="${area_GEC}-${port}-"
area_GEC0="${area_GEC^^}"
ip_txt="ip/${area_GEC0}-${port}.txt"
result_csv="log/${area_GEC0}-${port}.csv"

if [ ! -f "$ip_txt" ]; then
    echo "$area_GEC0 地区IP文件 $ip_txt 不存在。脚本终止。"
    exit 1
fi

echo "$area_GEC0 地区IP文件 $ip_txt 存在"

local_IP=$(curl -s 4.ipw.cn)
#全球IP地理位置API请求和响应示例
local_IP_geo=$(curl -s http://ip-api.com/json/${local_IP}?lang=zh-CN)
# 使用jq解析JSON响应并提取所需的信息
status=$(echo "$local_IP_geo" | jq -r '.status')

if [ "$status" = "success" ]; then
    countryCode=$(echo "$local_IP_geo" | jq -r '.countryCode')
    country=$(echo "$local_IP_geo" | jq -r '.country')
    regionName=$(echo "$local_IP_geo" | jq -r '.regionName')
    city=$(echo "$local_IP_geo" | jq -r '.city')
    # 如果status等于success，则显示地址信息
    # echo "您的地址是 ${country}${regionName}${city}"
    # 判断countryCode是否等于CN
    if [ "$countryCode" != "CN" ]; then
        echo "你的IP地址是 $local_IP ${country}${regionName}${city} 经确认本机网络使用了代理，请关闭代理后重试。"
        exit 1  # 在不是中国的情况下强行退出脚本
    else
        echo "你的IP地址是 $local_IP ${country}${regionName}${city} 经确认本机网络未使用代理..."
    fi
else
    echo "你的IP地址是 $local_IP 地址判断请求失败，请自行确认为本机网络未使用代理..."
fi

echo "待处理域名 ${record_name}[1~${record_count}].${zone_name}"

#./CloudflareST -tp 443 -url "https://cs.cmliussss.link" -f "ip/HK.txt" -dn 128 -tl 260 -p 0 -o "log/HK.csv"
./CloudflareST -tp $port -url $speedurl -f $ip_txt -dn $speedqueue -tl 280 -tlr $lossmax -p 0 -sl $speedlower -o $result_csv

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
