# AutoCloudflareSpeedTest

### 测速IP后将IP更新至CloudFlare域名A记录

一键脚本

```
wget -N -P cs https://raw.githubusercontent.com/cmliu/AutoCloudflareSpeedTest/main/speed.sh && cd cs && chmod +x speed.sh && ./speed.sh [测速国家代码] [端口] [域名数量] [主域名] [CloudFlare账户邮箱] [CloudFlare账户key]
```
## 手动运行:

运行前先去CloudFlare创建4条A记录,A记录IP随意即可

```
hk-443-1.xxxx.com
hk-443-2.xxxx.com
hk-443-3.xxxx.com
hk-443-4.xxxx.com
```

然后运行以下脚本即可自动更新
```
# ./speed.sh [测速国家代码] [端口] [域名数量] [主域名] [CloudFlare账户邮箱] [CloudFlare账户key]
$ ./speed.sh hk 443 4 xxxx.com xxxx@gmail.com xxxxxxxxxxxxxxx
```
## 计划任务:

运行前同样需要先去CloudFlare创建4条A记录,A记录IP随意即可

```
hk-443-1.xxxx.com
hk-443-2.xxxx.com
hk-443-3.xxxx.com
hk-443-4.xxxx.com
```

先修改speed.sh脚本内`auth_email`、`auth_key`、`zone_name`的值
```
auth_email="xxxx@gmail.com"    #你的CloudFlare注册账户邮箱 *必填
auth_key="xxxxxxxxxxxxxxx"   #你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。*必填
zone_name="xxxx.com"     #你的主域名 *必填
```

默认测速端口是443,默认测速域名数量为4
```
# ./speed.sh [测速国家代码] [端口] [域名数量]
$ ./speed.sh hk
```
## 文件结构

运行脚本后会自动下载所需文件,所以推荐将脚本放在单独目录下运行

```
cs
 ├─ speed.sh        #脚本本体
 ├─ CloudflareST    #CloudflareST测速程序
 ├─ ip              #测速地区ip库
 │   ├─ HK-443.txt
 │   ├─ JP-443.txt
 │  ...
 │   └─ US-443.txt
 ├─ log             #测速结果
 │   ├─ HK-443.csv
 │   ├─ JP-443.csv
 │  ...
 │   └─ US-443.csv
 ├─ temp            #整理IP库的临时文件夹
 │   ├─ 132203-1-443.txt
 │  ...
 │   └─ hello-earth-ip.txt
 ├─ ip-443.txt      #指定端口的完整不分区IP库
...
 └─ ip-8443.txt
```

 # 感谢
 
 [MaxMind](https://www.maxmind.com/)、[P3TERX](https://github.com/P3TERX/GeoLite.mmdb)、[XIU2](https://github.com/XIU2/CloudflareSpeedTest)、[hello-earth](https://github.com/hello-earth/cloudflare-better-ip)...
