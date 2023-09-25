import os
import socket
import subprocess

# 清除本机DNS缓存
def clear_dns_cache():
    try:
        if os.name == 'posix':  # 如果是Linux或macOS
            subprocess.run(["sudo", "systemctl", "restart", "systemd-resolved"])
        elif os.name == 'nt':  # 如果是Windows
            subprocess.run(["ipconfig", "/flushdns"], shell=True)
        else:
            print("不支持的操作系统")
    except Exception as e:
        print(f"清除DNS缓存时发生错误: {e}")

# 定义输入文件和输出文件的路径
input_file = 'yxym.txt'
output_file = 'temp/yxip.txt'

# 定义要使用的DNS服务器
dns_servers = ['114.114.114.114', '119.28.28.28', '223.5.5.5', '8.8.8.8', '208.67.222.222']

# 清除本机DNS缓存
clear_dns_cache()

# 设置默认的DNS服务器
socket.setdefaulttimeout(5)  # 设置解析超时时间为5秒

# 打开输入文件以读取域名
try:
    with open(input_file, 'r') as f:
        lines = f.readlines()
except FileNotFoundError:
    print(f"找不到文件 {input_file}")
    exit()

# 准备一个用于存储解析后IP的列表
ip_addresses = []

# 遍历每行域名并解析IP
for line in lines:
    # 去除行首和行尾的空白字符
    domain = line.strip()
    
    # 如果行为空白，则跳过
    if not domain:
        continue

    # 遍历DNS服务器进行解析
    for dns_server in dns_servers:
        try:
            ips = socket.gethostbyname_ex(domain)[2]
            ip_addresses.extend(ips)  # 将解析得到的所有IP添加到列表中
            
            # 输出解析结果
            print(f"域名: {domain}, DNS服务器: {dns_server}, IP地址: {ips}")
        except socket.gaierror:
            print(f"无法解析域名 {domain} 使用DNS服务器 {dns_server}")

# 去重
ip_addresses = list(set(ip_addresses))

# 追加解析后的IP到输出文件
try:
    with open(output_file, 'a') as f:  # 使用 'a' 模式以追加方式打开文件
        for ip in ip_addresses:
            f.write(ip + '\n')
except FileNotFoundError:
    print(f"找不到文件 {output_file}")
else:
    print(f"解析完成，IP地址已追加到 {output_file}")
