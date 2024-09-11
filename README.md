# AutoCloudflareSpeedTest 

这是一个自动测速CF优选IP后将IP更新至CF域名A记录的自动化脚本

测试运行环境ubuntu-18.04-standard_18.04.1-1_amd64

## 1. 单域名对单IP，测速并更新
<details>
<summary><code><strong>「 点击查看 speed.sh 脚本使用示例 」</strong></code></summary>
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
| speedurl |自定义测速地址 | × | 默认https://vipcs.cloudflarest.link |

## 事前准备
~~运行前先去CloudFlare创建4条A记录,A记录IP随意即可~~ 直接运行即可
```
默认 香港地区,端口443,数量4
hk-443-1.xxxx.com
hk-443-2.xxxx.com
hk-443-3.xxxx.com
hk-443-4.xxxx.com

如需自定义地区端口数量可自行调整
[测速国家代码]-[端口]-[域名数量].[主域名]

例如:
脚本命令:
sh speed.sh kr
对应创建域名
kr-443-1.xxxx.com
kr-443-2.xxxx.com
kr-443-3.xxxx.com
kr-443-4.xxxx.com

脚本命令:
sh speed.sh jp 8443
对应创建域名
jp-8443-1.xxxx.com
jp-8443-1.xxxx.com
jp-8443-1.xxxx.com
jp-8443-1.xxxx.com

脚本命令:
sh speed.sh jp 2096 2 google.com
对应创建域名
jp-2096-1.google.com
jp-2096-2.google.com

```

## 手动运行:
先修改speed.sh脚本内`auth_email`、`auth_key`、`zone_name`的值
```
auth_email="xxxx@gmail.com"  #你的CloudFlare注册账户邮箱 *必填
auth_key="xxxxxxxxxxxxxxx"   #你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。*必填
zone_name="xxxx.com"         #你的主域名 *必填
```

修改后运行以下命令即可
``` bash
sh speed.sh                       #测速默认香港地区,默认端口443,默认数量4,修改域名为默认    hk-443-[1~4].xxxx.com
sh speed.sh kr                    #测速韩国地区,默认端口443,默认数量4,修改域名为默认        kr-443-[1~4].xxxx.com
sh speed.sh jp 8443               #测速日本地区,自定义端口8443,默认数量4,修改域名为默认     jp-8443-[1~4].xxxx.com
sh speed.sh jp 2096 2 google.com  #测速日本地区,自定义端口2096,自定义数量2,修改自定义域名为 jp-2096-[1~2].google.com
```

## 定时任务:
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
| speedurl |自定义测速地址 | × | 默认https://vipcs.cloudflarest.link |

默认测速端口是443,默认测速域名数量为4
``` bash
cd /root/cs && chmod +x speed.sh && sh speed.sh hk                    #测速香港地区,默认端口443,默认数量4,修改域名为默认        hk-443-[1~4].xxxx.com
cd /root/cs && chmod +x speed.sh && sh speed.sh kr                    #测速韩国地区,默认端口443,默认数量4,修改域名为默认        kr-443-[1~4].xxxx.com
cd /root/cs && chmod +x speed.sh && sh speed.sh jp 8443               #测速日本地区,自定义端口8443,默认数量4,修改域名为默认     jp-8443-[1~4].xxxx.com
cd /root/cs && chmod +x speed.sh && sh speed.sh jp 2096 2 google.com  #测速日本地区,自定义端口2096,自定义数量2,修改自定义域名为 jp-2096-[1~2].google.com
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
</details>

****

## 2. 单域名对多IP，测速并更新
<details>
<summary><code><strong>「 点击查看 speed_AIO.sh 脚本使用示例 」</strong></code></summary>
一键脚本
 
``` bash
$ wget -N -P cs https://raw.githubusercontent.com/cmliu/AutoCloudflareSpeedTest/main/speed_AIO.sh && cd cs && chmod +x speed_AIO.sh 
$ sh speed_AIO.sh [测速国家代码] [端口] [IP数量] [主域名] [CloudFlare账户邮箱] [CloudFlare账户key] [自定义测速地址]
```
| 参数名| 中文解释| 一键脚本参数必填项 | 备注(注意!参数必须按顺序填写)  |
|--------------------------|----------------|-----------------|-----------------|
| area_GEC |测速国家代码 |√ | hk、sg、kr、jp、us等常用国家代码，默认hk |
| port |端口  | √ | 443、2053、2083、2087、2096、8443，默认443 |
| ips |域名数量 | √ | 默认4 |
| zone_name |主域名 | √ | 默认xxxx.com |
| auth_email | CloudFlare账户邮箱 | √ | 默认xxxx@gmail.com |
| auth_key |CloudFlare账户key | √ | 默认xxxxxxxxxxxxxxx |
| speedurl |自定义测速地址 | × | 默认https://vipcs.cloudflarest.link |

## 事前准备
~~运行前先去CloudFlare创建对应测速域名的A记录，A记录IP随意即可~~

~~**注意：您想获取多少IP数量就对应创建多少A记录，如使用默认443端口,则二级域名后可不带端口**~~

## 手动运行:
先修改speed.sh脚本内`auth_email`、`auth_key`、`zone_name`的值
```
auth_email="xxxx@gmail.com"  #你的CloudFlare注册账户邮箱 *必填
auth_key="xxxxxxxxxxxxxxx"   #你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。*必填
zone_name="xxxx.com"         #你的主域名 *必填
```

修改后运行以下命令即可
``` bash
sh speed_AIO.sh                       #测速默认香港地区,默认端口443,修改域名为默认    hk.xxxx.com
sh speed_AIO.sh kr                    #测速韩国地区,默认端口443,修改域名为默认        kr.xxxx.com
sh speed_AIO.sh jp 8443 6             #测速日本地区,自定义端口8443,修改域名为默认     jp-8443.xxxx.com 6条IP记录
sh speed_AIO.sh jp 2096 8 google.com  #测速日本地区,自定义端口2096,修改自定义域名为     jp-2096.google.com 8条IP记录
```

## 定时任务:
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
| ips |域名数量 | × | 默认4 |
| zone_name |主域名 | × | 默认xxxx.com |
| auth_email | CloudFlare账户邮箱 | × | 默认xxxx@gmail.com |
| auth_key |CloudFlare账户key | × | 默认xxxxxxxxxxxxxxx |
| speedurl |自定义测速地址 | × | 默认https://vipcs.cloudflarest.link |

默认测速端口是443,默认测速域名数量为4
``` bash
cd /root/cs && chmod +x speed_AIO.sh && sh speed_AIO.sh hk                    #测速香港地区,默认端口443,修改域名为默认        hk.xxxx.com
cd /root/cs && chmod +x speed_AIO.sh && sh speed_AIO.sh kr                    #测速韩国地区,默认端口443,修改域名为默认        kr.xxxx.com
cd /root/cs && chmod +x speed_AIO.sh && sh speed_AIO.sh jp 8443               #测速日本地区,自定义端口8443,,修改域名为默认     jp-8443.xxxx.com
cd /root/cs && chmod +x speed_AIO.sh && sh speed_AIO.sh jp 2096 6 google.com  #测速日本地区,自定义端口2096,修改自定义域名为      jp-2096.google.com
```

## 文件结构
运行脚本后会自动下载所需文件,所以推荐将脚本放在单独目录下运行
```
cs
 ├─ speed_AIO.sh        #脚本本体
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
</details>

 # 感谢
 [xiaodao2026](https://github.com/xiaodao2026/speed)、[MaxMind](https://www.maxmind.com/)、[P3TERX](https://github.com/P3TERX/GeoLite.mmdb)、[XIU2](https://github.com/XIU2/CloudflareSpeedTest)、[hello-earth](https://github.com/hello-earth/cloudflare-better-ip)、[badafans](https://github.com/badafans/better-cloudflare-ip)、[科技KKK](https://www.youtube.com/@KJKKK2023)、[cmliu](https://github.com/cmliu/AutoCloudflareSpeedTest)等
