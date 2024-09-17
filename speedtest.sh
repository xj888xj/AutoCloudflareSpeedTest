#!/bin/bash

# Set environment variables
export LANG=zh_CN.UTF-8
proxygithub="" # 反代github加速地址，如果不需要可以将引号内容删除，如需修改请确保/结尾 例如"https://mirror.ghproxy.com/"

# Define functions
archAffix() {
    case "$(uname -m)" in
        i386|i686) echo '386' ;;
        x86_64|amd64) echo 'amd64' ;;
        armv8|arm64|aarch64) echo 'arm64' ;;
        s390x) echo 's390x' ;;
        *) echo '不支持的CPU架构!' && exit 1 ;;
    esac
}

update_gengxinzhi=0
apt_update() {
    if [ "$update_gengxinzhi" -eq 0 ]; then
        sudo apt-get update
        update_gengxinzhi=$((update_gengxinzhi + 1))
    fi
}

apt_install() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 未安装，开始安装..."
        apt_update
        sudo apt-get install -y "$1"
        echo "$1 安装完成！"
    fi
}

download_file() {
    local url="$1"
    local output="$2"
    if ! sudo curl -sSL -o "$output" "$url"; then
        echo "下载失败: $url"
        return 1
    fi
}

download_GeoLite_mmdb() {
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/P3TERX/GeoLite.mmdb/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "最新版本号: $latest_version"
    download_file "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/releases/download/$latest_version/GeoLite2-Country.mmdb" "/usr/share/GeoIP/GeoLite2-Country.mmdb"
}

download_CloudflareST() {
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/XIU2/CloudflareSpeedTest/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    latest_version=${latest_version:-"v2.2.5"}
    echo "下载版本号: $latest_version"
    
    local arch
    arch=$(archAffix)
    download_file "${proxygithub}https://github.com/XIU2/CloudflareSpeedTest/releases/download/$latest_version/CloudflareST_linux_$arch.tar.gz" "CloudflareST.tar.gz"
    sudo tar -xvf CloudflareST.tar.gz CloudflareST -C /
    sudo rm CloudflareST.tar.gz
}

# Install prerequisite packages
packages=(git curl unzip awk jq geoip-bin mmdb-bin)
for package in "${packages[@]}"; do
    apt_install "$package"
done

# Download IP database
if [ ! -f "/usr/share/GeoIP/GeoLite2-Country.mmdb" ]; then
    echo "文件 /usr/share/GeoIP/GeoLite2-Country.mmdb 不存在。正在下载..."
    download_GeoLite_mmdb || exit 1
    echo "下载完成。"
fi

# Download CloudflareST
if [ ! -f "/CloudflareST" ]; then
    echo "CloudflareST 未准备就绪。开始下载..."
    download_CloudflareST
    echo "CloudflareST 下载完成。"
fi

# Download IP list
download_file "https://zip.baipiao.eu.org" "txt.zip"
sudo mkdir -p temp/temp
sudo unzip -o txt.zip -d temp/temp/
sudo mv temp/temp/*-${port}.txt temp/
sudo rm -r temp/temp
sudo rm txt.zip
echo "baipiao.eu.org IP库下载完成。"

# Install Python 3 and requests library
if ! command -v pip3 &> /dev/null; then
    echo 'pip3 is not installed, installing now'
    apt_update
    sudo apt-get install -y python3-pip
fi

if ! python3 -c "import requests" &> /dev/null; then
    echo 'requests module is not installed, installing now'
    python3 -m pip install requests
fi

# Run CloudflareST
sudo ./CloudflareST -tp 443 -url https://speed.cloudflare.com/__down?bytes=10000000 -dn 10 -tl 280 -tll 20 -tlr 0.75 -sl 5 -f ip.txt -o log/result-ip.csv
