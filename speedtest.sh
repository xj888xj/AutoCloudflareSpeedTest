#!/bin/bash
# $ ./speed.sh hk 443 4 xxxx.com xxxx@gmail.com xxxxxxxxxxxxxxx https://vipcs.cloudflarest.link
export LANG=zh_CN.UTF-8
proxygithub="" #反代github加速地址，如果不需要可以将引号内容删除，如需修改请确保/结尾 例如"https://mirror.ghproxy.com/"

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
	sudo curl -L -o /usr/share/GeoIP/GeoLite2-Country.mmdb "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/releases/download/$geoiplookup_latest_version/GeoLite2-Country.mmdb"
}

# 检测是否已经安装了geoiplookup
if ! command -v geoiplookup &> /dev/null; then
    echo "geoiplookup 未安装，开始安装..."
    apt_update
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
	sudo curl -L -o /usr/share/GeoIP/GeoLite2-Country.mmdb "${proxygithub}https://github.com/P3TERX/GeoLite.mmdb/releases/download/$geoiplookup_latest_version/GeoLite2-Country.mmdb"
	
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
    #update_gengxin
    sudo apt install mmdb-bin -y
    echo "mmdblookup 安装完成！"
else
    echo "mmdblookup 已安装."
fi

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

# 下载txt.zip文件并另存为txt.zip
sudo curl -Lo txt.zip https://zip.baipiao.eu.org
# 解压txt.zip到temp文件夹
sudo mkdir -p temp/temp
sudo unzip -o txt.zip -d temp/temp/
sudo mv temp/temp/*-${port}.txt temp/
# 删除下载的zip文件
sudo rm -r temp/temp
sudo rm txt.zip
echo "baipiao.eu.org IP库下载完成。"

# 检查pip3是否已经安装
if ! command -v pip3 &> /dev/null
then
	echo 'pip3 is not installed, installing now'
	sudo apt-get update
	sudo apt-get install python3-pip -y
fi

# 检查requests库是否已经安装
python3 -c "\
try:
	import requests
except ImportError:
	pass
else:
	print('requests module is installed')
" &> /dev/null

# 如果requests库没有安装，则自动安装
if [ $? -ne 0 ]; then
	echo 'requests module is not installed, installing now'
	$(which python3) -m pip install requests
fi

#CloudflareST测试
#./CloudflareST -tp 443 -url "https://cs.cmliussss.link" -f "ip/HK.txt" -dn 128 -tl 260 -p 0 -o "log/HK.csv"
sudo ./CloudflareST -tp 443 -url https://spurl.api.030101.xyz/50mb -dn 10 -tl 280 -tll 40 -tlr 0 -sl 10 -f ip.txt -o log/result-ip.csv
#sudo ./CloudflareST -tp 443 -url https://spurl.api.030101.xyz/50mb -dn 10 -tl 280 -tll 40 -tlr 0 -sl 10 -f ip-443.txt -o log/result-443.csv
