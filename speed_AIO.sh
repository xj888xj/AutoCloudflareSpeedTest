#!/bin/bash

area_GEC="hk"    # 自动更新的二级域名前缀（必须取 hk sg kr jp us 等常用国家代码）
port=443 # 自定义测速端口（不能为空）
ips=4    # 获取更新 IP 的指定数量（默认为 4）
CFIPs=0    # 如果是官方 IP 就设为 1，第三方反代 IP 设为 0

speedtestMB=90 # 测速文件大小（单位 MB）
speedlower=10  # 自定义下载速度下限（单位 mb/s）
lossmax=0.75  # 自定义丢包几率上限（范围 0.00~1.00）
speedqueue_max=1 # 自定义测速 IP 冗余量
githubID="cmliu" # 自用 IP 库，也可以换成你自己的 GitHub 仓库，且仓库名必须是 "cloudflare-better-ip"
proxygithub="" # 反代 GitHub 加速地址https://mirror.ghproxy.com/
CloudFlareIP_password=""
speedurl="https://speed.cloudflare.com/__down?bytes=$((speedtestMB * 1000000))" # 官方测速链接

# --- 参数处理 ---
if [ -n "$1" ]; then 
    area_GEC="$1"
fi

if [ -n "$2" ]; then
    port="$2"
fi

if [ -n "$3" ]; then
    ips="$3"
fi

if [ -n "$4" ]; then 
    zone_name="$4"
fi

if [ -n "$5" ]; then
    auth_email="$5"
fi

if [ -n "$6" ]; then
    auth_key="$6"
fi

# --- 检测并安装必要软件 ---
apt_update() {
    if ! command -v apt &> /dev/null; then
        echo "apt 未安装，无法继续。"
        exit 1
    fi
    sudo apt update
}

apt_install() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 未安装，开始安装..."
        apt_update
        sudo apt install "$1" -y
        echo "$1 安装完成！"
    fi
}

apt_install git
apt_install curl
apt_install unzip
apt_install awk
apt_install jq

# --- 下载和更新 IP 库 ---
upip() {
    # 检测 temp 文件夹是否存在
    if [ -d "temp" ]; then
        echo "开始清理 IP 临时文件..."
        rm -r temp/*
        echo "清理 IP 临时文件完成。"
    else
        echo "创建 IP 临时文件。"
        mkdir -p temp
    fi

    # 下载 txt.zip 文件并另存为 txt.zip
    curl -Lo txt.zip https://zip.baipiao.eu.org
    # 解压 txt.zip 到 temp 文件夹
    mkdir -p temp/temp
    unzip -o txt.zip -d temp/temp/
    mv temp/temp/*-${port}.txt temp/
    # 删除下载的 zip 文件
    rm -r temp/temp
    rm txt.zip
    echo "baipiao.eu.org IP 库下载完成。"

    # 如果 port 等于 443，则执行更新 hello-earth IP 库
    if [ "$port" -eq 443 ]; then
        echo "验证更新 hello-earth IP 库"
        git clone "${proxygithub}https://github.com/hello-earth/cloudflare-better-ip.git"
        
        # 检查 cloudflare-better-ip/cloudflare 内是否有文件
        if [ -d "cloudflare-better-ip/cloudflare" ] && [ -n "$(ls -A cloudflare-better-ip/cloudflare)" ]; then
            echo "正在更新 hello-earth IP 库"
            # 复制 cloudflare-better-ip/cloudflare 内的文件到 temp 文件夹
            cat cloudflare-better-ip/cloudflare/*.txt > cloudflare-better-ip/cloudflare-ip.txt
            awk -F ":443" '{print $1}' cloudflare-better-ip/cloudflare-ip.txt > temp/hello-earth-ip.txt
            echo "hello-earth IP 库下载完成。"

            # 删除 cloudflare-better-ip 文件夹
            rm -r cloudflare-better-ip
        else
            echo "hello-earth IP 库 无更新内容"
        fi
    fi

    if [ -n "$githubID" ]; then
        echo "验证更新 ${githubID} IP 库"
        git clone "${proxygithub}https://github.com/${githubID}/cloudflare-better-ip.git"
        
        # 检查 cmliu/cloudflare-better-ip/cloudflare 内是否有文件
        if [ -d "cloudflare-better-ip" ] && [ -n "$(ls -A cloudflare-better-ip)" ]; then
            echo "正在更新 ${githubID} IP 库"
            # 复制 cloudflare-better-ip 内的文件到 temp 文件夹
            cp -r cloudflare-better-ip/*${port}.txt temp/
            echo "${githubID} IP 库下载完成。"

            # 删除 cloudflare-better-ip 文件夹
            rm -r cloudflare-better-ip
        else
            echo "${githubID} IP 库 无更新内容"
        fi
    fi

    if [ -n "$CloudFlareIP_password" ]; then
      echo "正在验证 CFIPS 库更新密码"
      status_code=$(curl --write-out %{http_code} --silent --output /dev/null -k https://xvxvxv:${CloudFlareIP_password}@ip.ssrc.cf/CloudFlareIP-${port}.txt)
      if [ "$status_code" -eq 200 ]; then
        echo "验证成功 开始更新 CFIPS 库"
        curl -k -Lo temp/CloudFlareIP-${port}.txt https://xvxvxv:${CloudFlareIP_password}@ip.ssrc.cf/CloudFlareIP-${port}.txt
      else
        echo "密码有误或不存在当前端口的 CFIPS 库"
      fi
    fi

    cat temp/*.txt > ip_temp.txt
    awk '!a[$0]++' ip_temp.txt > ip-${port}.txt
    rm ip_temp.txt
    echo "去重合并整理 IP 库完成"
}

# --- 检查 IP 库是否需要更新 ---
if [ -e "ip-${port}.txt" ]; then
    file_timestamp=$(stat -c %Y ip-${port}.txt)
    current_timestamp=$(date +%s)
    time_diff=$((current_timestamp - file_timestamp))
    eight_hours_in_seconds=$((6 * 3600))

    if [ "$time_diff" -lt "$eight_hours_in_seconds" ]; then
        echo "ip-${port}.txt 文件已是最新版本，无需更新"
    else
        echo "ip-${port}.txt 文件已过期，开始更新整合 IP 库"
        upip
    fi
else
    echo "ip-${port}.txt 文件不存在，开始更新整合 IP 库"
    upip
fi

# --- 下载和配置 CloudflareST ---
download_CloudflareST() {
    latest_version=$(curl -s https://api.github.com/repos/XIU2/CloudflareSpeedTest/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$latest_version" ]; then
    	latest_version="v2.2.4"
    	echo "下载版本号: $latest_version"
    else
    	echo "最新版本号: $latest_version"
    fi

    curl -L -o CloudflareST.tar.gz "${proxygithub}https://github.com/XIU2/CloudflareSpeedTest/releases/download/$latest_version/CloudflareST_linux_$(archAffix).tar.gz"
    sudo tar -xvf CloudflareST.tar.gz CloudflareST -C /
	rm CloudflareST.tar.gz
}

archAffix() {
    case "$(uname -m)" in
        i386 | i686 ) echo '386' ;;
        x86_64 | amd64 ) echo 'amd64' ;;
        armv8 | arm64 | aarch64 ) echo 'arm64' ;;
        s390x ) echo 's390x' ;;
        * ) echo "不支持的 CPU 架构!" && exit 1 ;;
    esac
}

max_attempts=5
current_attempt=1

while [ $current_attempt -le $max_attempts ]; do
    if [ -f "CloudflareST" ]; then
        echo "CloudflareST 准备就绪。"
        break
    else
        echo "CloudflareST 未准备就绪。第 $current_attempt 次下载 CloudflareST ..."
        download_CloudflareST
    fi

    ((current_attempt++))
done

if [ $current_attempt -gt $max_attempts ]; then
    echo "连续 $max_attempts 次下载失败。请检查网络环境是否可以访问 GitHub 后重试。"
    exit 1
fi

area_GEC0="${area_GEC^^}"
ip_txt="ip/${area_GEC0}-${port}.txt"
result_csv="log/${area_GEC0}-${port}.csv"

if [ ! -f "$ip_txt" ]; then
    echo "$area_GEC0 地区 IP 文件 $ip_txt 不存在。脚本终止。"
    exit 1
fi

echo "$area_GEC0 地区 IP 文件 $ip_txt 存在"

# 检查 ip 文件夹是否存在
if [ -d "ip" ]; then
	echo "开始清理 IP 地区文件..."
	rm -r "ip"/*-${port}.txt
	echo "清理 IP 地区文件完成。"
else
	echo "创建 IP 地区文件。"
	mkdir -p ip
fi

echo "正在将 IP 按国家代码保存到 ip 文件夹内..."
while read -r line; do
	ip=$(echo $line | cut -d ' ' -f 1)
	result=$(mmdblookup --file /usr/share/GeoIP/GeoLite2-Country.mmdb --ip $ip country iso_code)
	country_code=$(echo $result | awk -F '"' '{print $2}')
	echo $ip >> "ip/${country_code}-${port}.txt"
done < ip-${port}.txt

echo "IP 已按国家分类保存到 ip 文件夹内。"

# 执行测速
./CloudflareST -tp $port -url $speedurl -f $ip_txt -dn $speedqueue -tl 280 -tlr $lossmax -p 0 -sl $speedlower -o $result_csv

echo "更新完成。"
