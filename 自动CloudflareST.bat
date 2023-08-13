@echo off
setlocal enabledelayedexpansion
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║                                                                        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo 更新IPDate
call 更新IPDate.bat

echo 更新IPDate_Plus
call 更新IPDate_Plus.bat

echo 整理IPDate到IP.txt
call 整理IPDate到IP.txt.bat

echo 执行自动测速任务
call speed.bat
