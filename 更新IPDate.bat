@echo off
setlocal

echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://www.baipiao.eu.org                                 ║
echo ╚════════════════════════════════════════════════════════════════════════╝

echo 正在运行 ip资源更新...
REM 设置下载文件和目录的名称
set downloadUrl=https://zip.baipiao.eu.org
set downloadFileName=txt.zip
set extractToDirectory=ip

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

echo 完成！文件已下载并解压到 "%extractToDirectory%" 目录下。
echo IP 资源更新完成。

Set delay=5
Set /p=倒计时<nul
:a
Set /p=%delay%<nul
Ping -n 2 127.1>nul
Set /a delay=%delay%-1
If %delay% equ 1 Goto b
Goto a
:b
Echo 执行完毕
