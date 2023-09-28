import os
import socket
import subprocess
import ipaddress

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
input_file = 'Domain.txt'
output_file = 'temp/Domain2IP.txt'

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

    # 禁用DNS缓存
    socket.setdefaulttimeout(0)
    ips0 = []
    print(f"解析域名: {domain}")
    # 遍历DNS服务器进行解析
    for dns_server in dns_servers:
        try:
            ips = socket.gethostbyname_ex(domain)[2]
            ips0.extend(ips)  # 将解析得到的所有IP添加到列表中
            ip_addresses.extend(ips)  # 将解析得到的所有IP添加到列表中
        except socket.gaierror as e:
            print(f"DNS服务器 {dns_server}无法解析域名 : {e}")
        except Exception as e:
            print(f"DNS服务器 {dns_server}发生未知错误 : {e}")

    # 去重
    ips0 = list(set(ips0))
    # 输出解析结果
    print(f"IP地址: {ips0}")

    # 恢复默认的解析超时
    socket.setdefaulttimeout(5)

# 去重
ip_addresses = list(set(ip_addresses))

# 定义删除CF官方IP地址段
ip_ranges_to_delete = [
    '173.245.48.0/20',
    '103.21.244.0/22',
    '103.22.200.0/22',
    '103.31.4.0/22',
    '141.101.64.0/18',
    '108.162.192.0/18',
    '190.93.240.0/20',
    '188.114.96.0/20',
    '197.234.240.0/22',
    '198.41.128.0/17',
    '162.158.0.0/15',
    '104.16.0.0/12',
    '172.64.0.0/17',
    '172.64.128.0/18',
    '172.64.192.0/19',
    '172.64.224.0/22',
    '172.64.229.0/24',
    '172.64.230.0/23',
    '172.64.232.0/21',
    '172.64.240.0/21',
    '172.64.248.0/21',
    '172.65.0.0/16',
    '172.66.0.0/16',
    '172.67.0.0/16',
    '131.0.72.0/22',
    '192.203.230.0/24'
]

# 过滤掉要删除的IP地址段
filtered_ip_addresses = []
for ip in ip_addresses:
    is_in_ranges = False
    for ip_range in ip_ranges_to_delete:
        if ipaddress.IPv4Address(ip) in ipaddress.IPv4Network(ip_range, strict=False):
            is_in_ranges = True
            break
    if not is_in_ranges:
        filtered_ip_addresses.append(ip)

# 追加解析后的IP到输出文件
try:
    with open(output_file, 'a') as f:  # 使用 'a' 模式以追加方式打开文件
        for ip in filtered_ip_addresses:
            f.write(ip + '\n')
except FileNotFoundError:
    print(f"找不到文件 {output_file}")
else:
    print(f"解析完成，IP地址已追加到 {output_file}")
