#!/bin/bash
export LANG=zh_CN.UTF-8
proxygithub="https://mirror.ghproxy.com"
area_GEC="hk"
port=443
ips=4
CFIPs=1
speedtestMB=90
speedlower=10
lossmax=0.75
speedqueue_max=1

speedurl="https://speed.cloudflare.com/__down?bytes=$((speedtestMB * 1000000))"

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
        apt_update
        sudo apt install "$1" -y
    fi
}

apt_install git curl unzip awk jq

download_GeoLite_mmdb() {
    geoiplookup_latest_version=$(curl -s https://api.github.com/repos/P3TERX/GeoLite.mmdb/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    sudo curl -L -o /usr/share/GeoIP/GeoLite2-Country.mmdb "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/releases/download/$geoiplookup_latest_version/GeoLite2-Country.mmdb"
}

if ! command -v geoiplookup &> /dev/null; then
    apt_update
    sudo apt install geoip-bin -y
    download_GeoLite_mmdb
fi

if [ ! -f "/usr/share/GeoIP/GeoLite2-Country.mmdb" ]; then
    sudo curl -L -o /usr/share/GeoIP/GeoLite2-Country.mmdb "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/releases/download/$geoiplookup_latest_version/GeoLite2-Country.mmdb"
fi

if ! command -v mmdblookup &> /dev/null; then
    apt_update
    sudo apt install mmdb-bin -y
fi

download_CloudflareST() {
    latest_version=$(curl -s https://api.github.com/repos/XIU2/CloudflareSpeedTest/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$latest_version" ]; then
    	latest_version="v2.2.5"
    fi
    sudo curl -L -o CloudflareST.tar.gz "${proxygithub}https://github.com/XIU2/CloudflareSpeedTest/releases/download/$latest_version/CloudflareST_linux_$(archAffix).tar.gz"
    sudo tar -xvf CloudflareST.tar.gz CloudflareST -C /
    sudo rm CloudflareST.tar.gz
}

max_attempts=3
current_attempt=1

while [ $current_attempt -le $max_attempts ]; do
    if [ -f "CloudflareST" ]; then
        break
    else
        download_CloudflareST
    fi
    ((current_attempt++))
done

if [ $current_attempt -gt $max_attempts ]; then
    exit 1
fi

upip(){
if [ -d "temp" ]; then
    sudo rm -r temp/*
else
    sudo mkdir -p temp
fi

sudo curl -Lo txt.zip https://zip.baipiao.eu.org
sudo mkdir -p temp/temp
sudo unzip -o txt.zip -d temp/temp/
sudo mv temp/temp/*-${port}.txt temp/
sudo rm -r temp/temp
sudo rm txt.zip

if [ "$port" -eq 443 ]; then
    sudo git clone "${proxygithub}https://github.com/hello-earth/cloudflare-better-ip.git"
    sudo cat cloudflare-better-ip/cloudflare/*.txt > cloudflare-better-ip/cloudflare-ip.txt
    awk -F ":443" '{print $1}' cloudflare-better-ip/cloudflare-ip.txt > temp/hello-earth-ip.txt
    sudo rm -r cloudflare-better-ip
fi

if [ -n "$githubID" ]; then
    sudo git clone "${proxygithub}https://github.com/${githubID}/cloudflare-better-ip.git"
    sudo cp -r cloudflare-better-ip/*${port}.txt temp/
    sudo rm -r cloudflare-better-ip
fi

if [ -n "$CloudFlareIP_password" ]; then
    status_code=$(curl --write-out %{http_code} --silent --output /dev/null -k https://xvxvxv:${CloudFlareIP_password}@ip.ssrc.cf/CloudFlareIP-${port}.txt)
    if [ "$status_code" -eq 200 ]; then
        sudo curl -k -Lo temp/CloudFlareIP-${port}.txt https://xvxvxv:${CloudFlareIP_password}@ip.ssrc.cf/CloudFlareIP-${port}.txt
    fi
fi

if [ -e "Domain.txt" ] && { [ "$port" -eq 443 ] || [ "$port" -eq 80 ]; }; then
    python3 Domain2IP.py
fi

sudo cat temp/*.txt > ip_temp.txt
sudo rm ip-${port}.txt
awk '!a[$0]++' ip_temp.txt > ip-${port}.txt
sudo rm ip_temp.txt

if [ "$CFIPs" -eq 0 ]; then
    if ! command -v pip3 &> /dev/null; then
        apt_update
        sudo apt install python3-pip -y
    fi
    if ! command -v pip &> /dev/null; then
        $(which python3) -m pip install requests
    fi
    if [ ! -f RemoveCFIPs.py ]; then
        sudo curl -L -O "${proxygithub}https://raw.githubusercontent.com/xj888xj/AutoCloudflareSpeedTest/main/RemoveCFIPs.py"
    fi
    python3 RemoveCFIPs.py ip-${port}.txt
fi

if [ -f "ip-${port}.txt" ]; then
	if [ -d "ip" ]; then
		sudo rm -r "ip"/*-${port}.txt
	else
		sudo mkdir -p ip
	fi
	while read -r line; do
	    ip=$(echo $line | cut -d ' ' -f 1)
		result=$(mmdblookup --file /usr/share/GeoIP/GeoLite2-Country.mmdb --ip $ip country iso_code)
		country_code=$(echo $result | awk -F '"' '{print $2}')
		sudo echo $ip >> "ip/${country_code}-${port}.txt"
    done < ip-${port}.txt
else
    exit 1
fi
}

if [ -f "ip-${port}.txt" ]; then
    file_timestamp=$(stat -c %Y ip-${port}.txt)
    current_timestamp=$(date +%s)
    time_diff=$((current_timestamp - file_timestamp))
    eight_hours_in_seconds=$((6 * 3600))
    if [ "$time_diff" -lt "$eight_hours_in_seconds" ]; then
        echo "ip-${port}.txt文件已是最新版本，无需更新"
    else
        upip
    fi
else
    upip
fi

if [ ! -d "log" ]; then
  mkdir log
fi

area_GEC0="${area_GEC^^}"
ip_txt="ip/${area_GEC0}-${port}.txt"
result_csv="log/${area_GEC0}-${port}.csv"

if [ ! -f "$ip_txt" ]; then
    exit 1
fi

speedqueue=$((ips + speedqueue_max))

sudo ./CloudflareST -tp $port -url $speedurl -f $ip_txt -dn $speedqueue -tl 280 -tll 30 -tlr $lossmax -sl $speedlower -o $result_csv
