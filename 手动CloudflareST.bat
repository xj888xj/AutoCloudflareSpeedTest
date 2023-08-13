@echo off
rem 自定义测速地址，可以参考@科技KKK视频制作自己专属的测速链接，避免拥挤造成的测速不准。https://www.youtube.com/watch?v=x1RFegiu0tU&t=271s
set speedurl="https://cs.cmliussss.link"

:zero
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║                                                                        ║
echo ╚════════════════════════════════════════════════════════════════════════╝

REM 检查目录下是否存在 CloudflareST.exe
if not exist "CloudflareST.exe" (
echo      CloudflareST.exe 未准备就绪
	goto :DownloadCloudflareST
) else (
echo      CloudflareST.exe 准备就绪
    goto :home
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

REM 清除屏幕上的内容
cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║                                                                        ║
echo ╚════════════════════════════════════════════════════════════════════════╝



:home
setlocal
REM 检查 ip 目录是否为空
set "ipDirectory=ip"
set "isEmpty=1"
for /f %%i in ('dir /b "%ipDirectory%"') do set "isEmpty=0"
if %isEmpty% equ 1 (
    echo 首次运行，将执行更新 IP 资源脚本。
    call :updateIPResources
	goto :home2
) 


	REM 设置默认值为 "N"
	set "updateChoice=N"

	REM 提示用户是否更新 IP 资源
	set /p "updateChoice=是否更新 IP 资源？(Y/N，默认为 N)："

	REM 将用户输入转换为大写，方便后续比较
	set "updateChoice=%updateChoice:~0,1%"
	set "updateChoice=%updateChoice:~0,1%"

	REM 如果用户选择 "Y" 或 "y"，则运行 ip资源更新.bat
	if /i "%updateChoice%"=="Y" (
		echo 用户选择更新 IP 资源。
		REM 在此处添加更新 IP 资源的操作，或者调用 :updateIPResources 子程序
		call :updateIPResources
	) else (
		echo 用户选择不更新 IP 资源。
		
	)

:home2
REM 继续执行其他操作
REM 设置目录和文件名
set sourceDirectory=ip
set "delayTime=160"
set "choice=1"
set "area=hk"


REM 用户选择
echo 请选择测速地区：
echo 1. HK香港
echo 2. SG新加坡
echo 3. KR韩国
echo 4. JP日本
echo 5. MO澳门
echo 6. TW台湾
echo 7. oracle甲骨文线路
echo 8. aliyun阿里云线路
echo 9. tencent腾讯云线路
REM 使用choice命令让用户选择，/c 参数指定合法的输入选项
choice /c 123456789 /n /m "选择 (默认为 1)："

REM 获取choice命令的返回值，%errorlevel% 表示用户选择的数字
set "choice=%errorlevel%"

REM 根据用户选择设置 area 和 delayTime
if "%choice%"=="1" (
    set "area=hk"
    set "delayTime=160"
) else if "%choice%"=="2" (
    set "area=sg"
    set "delayTime=200"
) else if "%choice%"=="3" (
    set "area=kr"
    set "delayTime=200"
) else if "%choice%"=="4" (
    set "area=jp"
    set "delayTime=200"
) else if "%choice%"=="5" (
    set "area=mo"
    set "delayTime=160"
) else if "%choice%"=="6" (
    set "area=tw"
    set "delayTime=200"
) else if "%choice%"=="7" (
    set "area=31898"
    set "delayTime=200"
) else if "%choice%"=="8" (
    set "area=45102"
    set "delayTime=200"
) else if "%choice%"=="9" (
    set "area=132203"
    set "delayTime=200"
) else (
    echo 无效的选择。批处理将现在结束。
    pause
    exit /b
)



REM 设置默认端口为 443
set "port=443"

REM 定义合法的端口列表
set "validPorts=443 2053 2083 2087 2096 8443"

REM 提示用户输入测速端口
:inputPort
set /p "portInput=请输入测速端口443 2053 2083 2087 2096 8443 (默认443)："

REM 如果用户输入了端口号，则检查是否在合法的端口列表中
REM 否则将保持默认值 443
if "%portInput%" neq "" (
    echo %validPorts% | find " %portInput% " > nul
    if errorlevel 1 (
        echo 无效的端口号，请输入合法的端口号。
        goto inputPort
    ) else (
        set "port=%portInput%"
    )
)

REM 提示用户当前设置的端口
REM echo 当前测速端口设置为 %port%

set sourceFileName=%area%-1-%port%.txt
REM 检查文件是否存在
if not exist "%sourceDirectory%\%sourceFileName%" (
    echo 文件 "%sourceFileName%" 不存在于目录 "%sourceDirectory%"。
	echo 没有%area%地区%port%端口的IP资源。
    echo 批处理将现在结束。
    pause
    exit /b
)

if "%area%" == "31898" (
    set "area=甲骨文"
)else if "%area%" == "45102" (
    set "area=阿里云"
)else if "%area%" == "132203" (
    set "area=腾讯云"
)
echo 测速地区:%area% 端口:%port% 延迟时间为:%delayTime% 测速IP文件:%sourceFileName% 测速链接:%speedurl%
pause
CloudflareST.exe -tp %port% -url %speedurl% -sl 5 -tl %delayTime% -dn 10 -f "%sourceDirectory%\%sourceFileName%" -o %area%%port%".csv"
goto :zero

exit /b

:updateIPResources
setlocal 
cls
call 更新IPDate.bat
cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║                                                                        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
exit /b
