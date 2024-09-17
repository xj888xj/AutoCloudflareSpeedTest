#!/bin/bash

# 导出语言
export LANG=zh_CN.UTF-8

# 配置常量
DEFAULT_AREA="hk"
DEFAULT_PORT=443
DEFAULT_IPS=4
DEFAULT_CFIPs=1
DEFAULT_SPEED_MB=90
DEFAULT_LOWER_LIMIT=10
DEFAULT_LOSS_LIMIT=0.75
DEFAULT_QUEUE_MAX=1
DEFAULT_GITHUB_ID="xj888xj"
DEFAULT_SPEED_URL="https://speed.cloudflare.com/__down?bytes=$((DEFAULT_SPEED_MB * 1000000))"

# 自定义变量
area_GEC=${1:-$DEFAULT_AREA}
port=${2:-$DEFAULT_PORT}
ips=${3:-$DEFAULT_IPS}
zone_name=$4
auth_email=$5
auth_key=$6
speedurl=${7:-$DEFAULT_SPEED_URL}
githubID=${DEFAULT_GITHUB_ID}

# 日志路径
LOG_DIR="log"
TEMP_DIR="temp"

# 记录日志
log_message() {
    local message="$1"
    echo "$message" | tee -a "$LOG_DIR/speedtest.log"
}

# 检测并安装依赖
apt_install() {
    local package="$1"
    if ! command -v "$package" &> /dev/null; then
        log_message "$package 未安装，开始安装..."
        sudo apt-get update
        sudo apt-get install "$package" -y
        log_message "$package 安装完成！"
    fi
}

# 初始化依赖
init_dependencies() {
    apt_install git
    apt_install curl
    apt_install unzip
    apt_install awk
    apt_install jq
}

# CPU 架构选择
archAffix() {
    case "$(uname -m)" in
        i386 | i686 ) echo '386' ;;
        x86_64 | amd64 ) echo 'amd64' ;;
        armv8 | arm64 | aarch64 ) echo 'arm64' ;;
        s390x ) echo 's390x' ;;
        * ) log_message "不支持的CPU架构!" && exit 1 ;;
    esac
}

# 下载文件并验证成功与否
download_file() {
    local url="$1"
    local output="$2"
    curl -Lo "$output" "$url"
    if [ $? -ne 0 ]; then
        log_message "下载 $output 失败，脚本终止。"
        exit 1
    fi
}

# 更新 GeoIP 数据库
update_geoip() {
    if ! command -v geoiplookup &> /dev/null; then
        log_message "geoiplookup 未安装，开始安装..."
        apt_install geoip-bin
        log_message "GeoLite.mmdb 开始更新..."
        download_file "https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download/GeoLite2-Country.mmdb" "/usr/share/GeoIP/GeoLite2-Country.mmdb"
        log_message "GeoLite.mmdb 更新完成！"
    fi
}

# 更新 CloudflareSpeedTest
update_cloudflareST() {
    local latest_version=$(curl -s https://api.github.com/repos/XIU2/CloudflareSpeedTest/releases/latest | jq -r '.tag_name')
    latest_version=${latest_version:-"v2.2.5"}
    
    log_message "最新版本号: $latest_version"
    download_file "https://github.com/XIU2/CloudflareSpeedTest/releases/download/$latest_version/CloudflareST_linux_$(archAffix).tar.gz" "CloudflareST.tar.gz"
    
    sudo tar -xvf CloudflareST.tar.gz -C /usr/local/bin/
    sudo rm CloudflareST.tar.gz
    log_message "CloudflareST 下载并解压完成。"
}

# 更新 IP 库
update_ip_libraries() {
    log_message "开始更新 IP 库..."
    
    if [ ! -d "$TEMP_DIR" ]; then
        mkdir -p "$TEMP_DIR"
    fi

    # 下载 zip 文件
    download_file "https://zip.baipiao.eu.org" "temp.zip"
    unzip -o temp.zip -d "$TEMP_DIR"
    
    # 删除 zip 文件
    rm temp.zip
    log_message "IP 库更新完成。"
}

# 核心测速函数
run_speed_test() {
    log_message "开始测速..."
    ./CloudflareST --url "$speedurl" --ips "$ips" --port "$port"
}

# 主程序执行逻辑
main() {
    log_message "脚本开始执行..."
    
    # 初始化依赖和更新
    init_dependencies
    update_geoip
    update_cloudflareST
    update_ip_libraries
    
    # 执行测速
    run_speed_test

    log_message "脚本执行完成。"
}

# 执行主函数
main
