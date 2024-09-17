#!/bin/bash

area_GEC0="${area_GEC^^}"
ip_txt="ip/${area_GEC0}-${port}.txt"
result_csv="log/${area_GEC0}-${port}.csv"

# 设置错误处理
set -e
trap 'echo "错误: 脚本在第 $LINENO 行失败"; cleanup' ERR

# 日志函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 清理函数
cleanup() {
  rm -rf temp
  rm -f CloudflareST.tar.gz
  rm -f RemoveCFIPs.py
  rm -f Domain2IP.py
}

# 检查依赖
check_dependencies() {
  sudo apt-get update
  sudo apt-get install -y curl unzip jq geoip-bin mmdb-bin python3-pip
  pip3 install requests
}

# 下载 CloudflareST
download_CloudflareST() {
  latest_version=$(curl -s https://api.github.com/repos/XIU2/CloudflareSpeedTest/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  if [ -z "$latest_version" ]; then
    latest_version="v2.5.0"
  fi
  log "下载 CloudflareST 版本: $latest_version"
  curl -L -o CloudflareST.tar.gz "https://github.com/XIU2/CloudflareSpeedTest/releases/download/$latest_version/CloudflareST_linux_amd64.tar.gz"
  tar -xzf CloudflareST.tar.gz CloudflareST
  chmod +x CloudflareST
}

# 更新 IP 库
update_ip_library() {
  mkdir -p temp
  curl -Lo txt.zip https://zip.baipiao.eu.org
  unzip -o txt.zip -d temp
  mv temp/*-${PORT}.txt temp/
  rm txt.zip

  if [ "$PORT" -eq 443 ]; then
    log "更新 hello-earth IP 库"
    git clone "https://github.com/hello-earth/cloudflare-better-ip.git"
    if [ -d "cloudflare-better-ip/cloudflare" ] && [ "$(ls -A cloudflare-better-ip/cloudflare)" ]; then
      cat cloudflare-better-ip/cloudflare/*.txt > cloudflare-better-ip/cloudflare-ip.txt
      awk -F ":443" '{print $1}' cloudflare-better-ip/cloudflare-ip.txt > temp/hello-earth-ip.txt
    fi
    rm -rf cloudflare-better-ip
  fi

  if [ -n "$GITHUB_ID" ]; then
    log "更新 ${GITHUB_ID} IP 库"
    git clone "https://github.com/${GITHUB_ID}/cloudflare-better-ip.git"
    if [ -d "cloudflare-better-ip" ] && [ "$(ls -A cloudflare-better-ip)" ]; then
      cp cloudflare-better-ip/*${PORT}.txt temp/
    fi
    rm -rf cloudflare-better-ip
  fi

  cat temp/*.txt > ip-${PORT}.txt
  sort -u ip-${PORT}.txt -o ip-${PORT}.txt
  log "IP 库更新完成"
}

# 运行速度测试
run_speed_test() {
  log "开始运行速度测试"
  ./CloudflareST -tp $PORT -url $SPEEDURL -f ip-${PORT}.txt -dn $IPS -tl 280 -tll 30 -tlr $LOSS_MAX -sl $SPEED_LOWER -o $result_csv
  log "速度测试完成"
}

# 更新 DNS 记录
update_dns_records() {
  log "开始更新 DNS 记录"
  zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME" -H "X-Auth-Email: $AUTH_EMAIL" -H "X-Auth-Key: $AUTH_KEY" -H "Content-Type: application/json" | jq -r '.result[0].id')
  
  if [ "$PORT" -eq 443 ]; then
    record_name="${AREA_GEC}"
  else
    record_name="${AREA_GEC}-${PORT}"
  fi

  readarray -t ips < <(awk -F',' '{print $1}' result.csv | tail -n +2 | head -n $IPS)
  
  for ip in "${ips[@]}"; do
    result=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_id" \
         -H "X-Auth-Email: $AUTH_EMAIL" \
         -H "X-Auth-Key: $AUTH_KEY" \
         -H "Content-Type: application/json" \
         --data "{\"type\":\"A\",\"name\":\"$record_name.$ZONE_NAME\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}")
    
    success=$(echo "$result" | jq -r '.success')
    if [ "$success" = "true" ]; then
      log "DNS 记录更新成功: $ip"
    else
      log "DNS 记录更新失败: $ip"
    fi
  done
}

# 主函数
main() {
  log "脚本开始执行"
  check_dependencies
  download_CloudflareST
  update_ip_library
  run_speed_test
  update_dns_records
  log "脚本执行完成"
}

# 执行主函数
main