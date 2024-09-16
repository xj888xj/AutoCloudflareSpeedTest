#!/bin/bash

# Set environment variables
export LANG=zh_CN.UTF-8
proxygithub="" #反代github加速地址，如果不需要可以将引号内容删除，如需修改请确保/结尾 例如"https://mirror.ghproxy.com/"

# Define functions
archAffix() {
    case "$(uname -m)" in
        i386 | i686 ) echo '386' ;;
        x86_64 | amd64 ) echo 'amd64' ;;
        armv8 | arm64 | aarch64 ) echo 'arm64' ;;
        s390x ) echo 's390x' ;;
        * ) echo '不支持的CPU架构!' && exit 1 ;;
    esac
}

update_gengxinzhi=0
apt_update() {
    if [ "$update_gengxinzhi" -eq 0 ]; then
        sudo apt update
        update_gengxinzhi=$((update_gengxinzhi + 1))
    fi
}

apt_install() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 未安装，开始安装..."
        apt_update
        sudo apt install "$1" -y
        echo "$1 安装完成！"
    fi
}

download_GeoLite_mmdb() {
    # 发送 API 请求获取仓库信息（替换 <username> 和 <repo>）
    geoiplookup_latest_version=$(curl -s https://api.github.com/repos/P3TERX/GeoLite.mmdb/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "最新版本号: $geoiplookup_latest_version"
    # 下载文件到当前目录
    sudo curl -L -o /usr/share/GeoIP/GeoLite2-Country.mmdb "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/releases/download/$geoiplookup_latest_version/GeoLite2-Country.mmdb"
}

download_CloudflareST() {
    # 发送 API 请求获取仓库信息（替换 <username> 和 <repo>）
    latest_version=$(curl -s https://api.github.com/repos/XIU2/CloudflareSpeedTest/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$latest_version" ]; then
        latest_version="v2.2.5"
        echo "下载版本号: $latest_version"
    else
        echo "最新版本号: $latest_version"
    fi
    # 下载文件到当前目录
    sudo curl -L -o CloudflareST.tar.gz "${proxygithub}https://github.com/XIU2/CloudflareSpeedTest/releases/download/$latest_version/CloudflareST_linux_$(archAffix).tar.gz"
    # 解压CloudflareST文件到当前目录
    sudo tar -xvf CloudflareST.tar.gz CloudflareST -C /
    sudo rm CloudflareST.tar.gz
}

# Install prerequisite packages
apt_install git
apt_install curl
apt_install unzip
apt_install awk
apt_install jq
apt_install geoip-bin
apt_install mmdb-bin

# Download IP database
if [ ! -f "/usr/share/GeoIP/GeoLite2-Country.mmdb" ]; then
    echo "文件 /usr/share/GeoIP/GeoLite2-Country.mmdb 不存在。正在下载..."

    # 使用curl命令下载文件
    sudo curl -L -o /usr/share/GeoIP/GeoLite2-Country.mmdb "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/releases/download/$geoiplookup_latest_version/GeoLite2-Country.mmdb"

    # 检查下载是否成功
    if [ $? -eq 0 ]; then
        echo "下载完成。"
    else
        echo "下载失败。脚本终止。"
        exit 1
    fi
fi

# Download CloudflareST
if [ ! -f "CloudflareST" ]; then
    echo "CloudflareST 未准备就绪。开始下载..."
    download_CloudflareST
    echo "CloudflareST 下载完成。"
fi

# Download IP list
sudo curl -Lo txt.zip https://zip.baipiao.eu.org
sudo mkdir -p temp/temp
sudo unzip -o txt.zip -d temp/temp/
sudo mv temp/temp/*-${port}.txt temp/
sudo rm -r temp/temp
sudo rm txt.zip
echo "baipiao.eu.org IP库下载完成。"

# Install Python 3 and requests library
if ! command -v pip3 &> /dev/null; then
    echo 'pip3 is not installed, installing now'
    sudo apt-get update
    sudo apt-get install python3-pip -y
fi

python3 -c "\
try:
    import requests
except ImportError:
    pass
else:
    print('requests module is installed')
" &> /dev/null

if [ $? -ne 0 ]; then
    echo 'requests module is not installed, installing now'
    $(which python3) -m pip install requests
fi

# Run CloudflareST
sudo ./CloudflareST -tp 443 -url https://speed.cloudflare.com/__down?bytes=10000000 -dn 10 -tl 280 -tll 20 -tlr 0.75 -sl 5 -f ip.txt -o log/result-ip.csv

