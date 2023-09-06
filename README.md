# AutoCloudflareSpeedTest
白嫖总得来说不好，请不要公开传播，项目热度太高就删库
## 测速IP后将IP更新至CloudFlare域名A记录
测试运行环境ubuntu-18.04-standard_18.04.1-1_amd64

一键脚本
``` bash
$ wget -N -P cs https://raw.githubusercontent.com/cmliu/AutoCloudflareSpeedTest/main/speed.sh && cd cs && chmod +x speed.sh 
$ sh speed.sh [测速国家代码] [端口] [域名数量] [主域名] [CloudFlare账户邮箱] [CloudFlare账户key] [自定义测速地址]
```
| 参数名| 中文解释| 一键脚本参数必填项 | 备注(注意!参数必须按顺序填写)  |
|--------------------------|----------------|-----------------|-----------------|
| area_GEC |测速国家代码 |√ | hk、sg、kr、jp、us等常用国家代码，默认hk |
| port |端口  | √ | 443、2053、2083、2087、2096、8443，默认443 |
| record_count |域名数量 | √ | 默认4 |
| zone_name |主域名 | √ | 默认xxxx.com |
| auth_email | CloudFlare账户邮箱 | √ | 默认xxxx@gmail.com |
| auth_key |CloudFlare账户key | √ | 默认xxxxxxxxxxxxxxx |
| speedurl |自定义测速地址 | × | 默认https://speed.cloudflare.com/__down?bytes=100000000 |

## 手动运行:
运行前先去CloudFlare创建4条A记录,A记录IP随意即可
```
hk-443-1.xxxx.com
hk-443-2.xxxx.com
hk-443-3.xxxx.com
hk-443-4.xxxx.com
```

先修改speed.sh脚本内`auth_email`、`auth_key`、`zone_name`的值
```
auth_email="xxxx@gmail.com"  #你的CloudFlare注册账户邮箱 *必填
auth_key="xxxxxxxxxxxxxxx"   #你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。*必填
zone_name="xxxx.com"         #你的主域名 *必填
```

修改后运行以下命令即可
``` bash
sh speed.sh                       #测速默认香港地区,默认端口443,默认数量4,修改域名为默认hk-443-[1~4].xxxx.com
sh speed.sh kr                    #测速韩国地区,默认端口443,默认数量4,修改域名为默认kr-443-[1~4].xxxx.com
sh speed.sh jp 8443               #测速日本地区,自定义端口8443,默认数量4,修改域名为默认jp-8443-[1~4].xxxx.com
sh speed.sh jp 2096 2 google.com  #测速日本地区,自定义端口2096,默认数量2,修改域名为默认jp-2096-[1~2].google.com
```

## 定时任务:
运行前同样需要先去CloudFlare创建4条A记录,A记录IP随意即可
```
hk-443-1.xxxx.com
hk-443-2.xxxx.com
hk-443-3.xxxx.com
hk-443-4.xxxx.com
```

先修改speed.sh脚本内`auth_email`、`auth_key`、`zone_name`的值
```
auth_email="xxxx@gmail.com"  #你的CloudFlare注册账户邮箱 *必填
auth_key="xxxxxxxxxxxxxxx"   #你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。*必填
zone_name="xxxx.com"         #你的主域名 *必填
```
| 参数名| 中文解释| 修改`auth_email`、`auth_key`、`zone_name`值之后的必填项 | 备注(注意!参数必须按顺序填写)  |
|--------------------------|----------------|-----------------|-----------------|
| area_GEC |测速国家代码 |× | hk、sg、kr、jp、us等常用国家代码，默认hk |
| port |端口  | × | 443、2053、2083、2087、2096、8443，默认443 |
| record_count |域名数量 | × | 默认4 |
| zone_name |主域名 | × | 默认xxxx.com |
| auth_email | CloudFlare账户邮箱 | × | 默认xxxx@gmail.com |
| auth_key |CloudFlare账户key | × | 默认xxxxxxxxxxxxxxx |
| speedurl |自定义测速地址 | × | 默认https://speed.cloudflare.com/__down?bytes=100000000 |

默认测速端口是443,默认测速域名数量为4
``` bash
cd /root/cs
chmod +x speed.sh
sh speed.sh                       #测速默认香港地区,默认端口443,默认数量4,修改域名为默认hk-443-[1~4].xxxx.com
sh speed.sh kr                    #测速韩国地区,默认端口443,默认数量4,修改域名为默认kr-443-[1~4].xxxx.com
sh speed.sh jp 8443               #测速日本地区,自定义端口8443,默认数量4,修改域名为默认jp-8443-[1~4].xxxx.com
sh speed.sh jp 2096 2 google.com  #测速日本地区,自定义端口2096,默认数量2,修改域名为默认jp-2096-[1~2].google.com
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
 [xiaodao2026](https://github.com/xiaodao2026/speed)、[MaxMind](https://www.maxmind.com/)、[P3TERX](https://github.com/P3TERX/GeoLite.mmdb)、[XIU2](https://github.com/XIU2/CloudflareSpeedTest)、[hello-earth](https://github.com/hello-earth/cloudflare-better-ip)、[badafans](https://github.com/badafans/better-cloudflare-ip)等
