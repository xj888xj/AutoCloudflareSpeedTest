@echo off
setlocal enabledelayedexpansion

REM 检查目录下是否存在 CloudflareST.exe
if not exist "CloudflareST.exe" (
echo CloudflareST.exe 未准备就绪
	goto :DownloadCloudflareST
) else (
echo CloudflareST.exe 准备就绪
    goto :curl
)

:DownloadCloudflareST
REM 设置 GitHub 仓库信息
set "githubRepoOwner=XIU2"
set "githubRepoName=CloudflareSpeedTest"

REM 使用 PowerShell 获取 GitHub API 数据并解析 JSON
for /f "usebackq tokens=*" %%a in (`powershell -command "(Invoke-WebRequest -Uri 'https://api.github.com/repos/%githubRepoOwner%/%githubRepoName%/releases/latest' | ConvertFrom-Json).tag_name" 2^>nul`) do (
    set "latestVersion=%%~a"
    goto :gotVersion
)

:gotVersion
REM 输出获取到的最新版本号
if not "%latestVersion%"=="" (
    echo 最新的版本号为：%latestVersion%
) else (
    echo 无法获取最新的版本号。
    pause
    exit /b
)

REM 构建下载链接和文件名
set "downloadUrl=https://ghproxy.com/https://github.com/%githubRepoOwner%/%githubRepoName%/releases/download/%latestVersion%/CloudflareST_windows_amd64.zip"
set "zipFileName=CloudflareST_windows_amd64.zip"
REM 使用 PowerShell 下载 ZIP 文件
powershell -command "(New-Object System.Net.WebClient).DownloadFile('%downloadUrl%', '%zipFileName%')"
REM 使用 PowerShell 解压 ZIP 文件
powershell -command "Expand-Archive -Path '%zipFileName%' -DestinationPath '.' -Force"
REM 删除下载的 ZIP 文件
del "%zipFileName%"

:curl
REM 检查目录下是否存在 curl.exe
if not exist ".\curl\curl-8.2.1_5-win64-mingw\bin\curl.exe" (
echo curl.exe 未准备就绪
    goto :Downloadcurl
) else (
echo curl.exe 准备就绪
    goto :start
)

:Downloadcurl
REM 设置下载文件和目录的名称 https://curl.se/windows/dl-8.2.1_5/curl-8.2.1_5-win64-mingw.zip
set downloadUrl=https://downloadcurl.cmliu.net/
set downloadFileName=curl.zip
set extractToDirectory=curl

REM 删除目标目录下的所有内容
if exist "%extractToDirectory%" (
    echo 正在删除目录 "%extractToDirectory%" 中的所有内容...
    rmdir /s /q "%extractToDirectory%"
)

REM 创建目标目录
mkdir "%extractToDirectory%"
REM 下载文件
echo 正在下载文件...
powershell -NonInteractive -command "& { (New-Object Net.WebClient).DownloadFile('%downloadUrl%', '%downloadFileName%') }"
REM 解压文件
echo 正在解压文件...
powershell -NonInteractive -command "& { Expand-Archive -Path '%downloadFileName%' -DestinationPath '%extractToDirectory%' }"
REM 清理临时文件
del "%downloadFileName%"
echo      curl.exe 准备就绪

:start

rem 你的CloudFlare注册账户邮箱
set auth_email=xxxxx@gmail.com
rem 你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。
set auth_key=xxxxxxxxxxxxxx
rem #修改为你的主域名
set zone_name=mcetf.eu.org
rem 自动更新的二级域名前缀,例如cloudflare的cdn用cl，gcore的cdn用gcore，后面是数字，程序会自动添加。
set record_name=gcore
rem 二级域名个数，例如配置5个，则域名分别是cl1、cl2、cl3、cl4、cl5.   后面的信息均不需要修改，让他自动运行就好了。
set record_count=5
set record_type=A

for /F %%I in ('.\curl\bin\curl.exe --silent http://4.ipw.cn') do set PUBLIC_IP=%%I
echo '请确认该机器没有通过代理，你的IP地址是：'%PUBLIC_IP%
echo '欢迎关注youtuber小道笔记：https://www.youtube.com/channel/UCfSvDIQ8D_Zz62oAd5mcDDg'
set /a record_count+=1

CloudflareST.exe -url https://cs.cmliussss.link -p 0
for /F %%I in ('.\curl\bin\curl.exe -X GET "https://api.cloudflare.com/client/v4/zones?name=%zone_name%" -H "X-Auth-Email: %auth_email%" -H "X-Auth-Key: %auth_key%" -H "Content-Type: application/json"') do set zone_identifier=%%I
echo zone_id:%zone_identifier:~18,32%

set /a n=0
for /f "tokens=1 delims=," %%i in (result.csv) do (
	if !n! neq 0 (
		for /F %%I in ('.\curl\bin\curl.exe -X GET "https://api.cloudflare.com/client/v4/zones/%zone_identifier:~18,32%/dns_records?name=%record_name%!record_count!.%zone_name%" -H "X-Auth-Email: %auth_email%" -H "X-Auth-Key: %auth_key%" -H "Content-Type: application/json"') do set record=%%I
		echo record_id:!record:~18,32!
		::echo "https://api.cloudflare.com/client/v4/zones/%zone_identifier:~18,32%/dns_records/!record:~18,32!" -H "X-Auth-Email: %auth_email%" -H "X-Auth-Key: %auth_key%" -H "Content-Type: application/json" --data "{\"type\":\"%record_type%\",\"name\":\"%record_name%!record_count!.%zone_name%\",\"content\":\"%%i\",\"ttl\":60,\"proxied\":false}"
		echo 更新DNS记录
		for /F %%I in ('.\curl\bin\curl.exe -X PUT "https://api.cloudflare.com/client/v4/zones/%zone_identifier:~18,32%/dns_records/!record:~18,32!" -H "X-Auth-Email: %auth_email%" -H "X-Auth-Key: %auth_key%" -H "Content-Type: application/json" --data "{\"type\":\"%record_type%\",\"name\":\"%record_name%!record_count!.%zone_name%\",\"content\":\"%%i\",\"ttl\":60,\"proxied\":false}"') do set result=%%I
		echo %record_name%!record_count!.%zone_name%域名地址更新为:%%i
    	echo 更新结果：!result:~-41,14!		
	    )
	set /a n+=1
	set /a record_count-=1
	if !record_count! LEQ 0 (
		goto :END
	)
)
:END
