@echo off
setlocal
cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo =------------------------------------------------- 1%%
echo 正在运行 ip资源更新...


REM 设置下载文件和目录的名称
set downloadUrl=https://ghproxy.com/https://github.com/hello-earth/cloudflare-better-ip/archive/refs/heads/main.zip
set downloadFileName=ip.zip
set extractToDirectory=ip

REM 检查当前目录下是否存在 ip 文件夹
if not exist "ip" (
    echo 未找到 ip 文件夹，将创建一个新的 ip 文件夹。
    mkdir "ip"
) else (
    echo ip 文件夹已存在。
)

REM 下载文件
echo 正在下载文件...
powershell -NonInteractive -command "& { (New-Object Net.WebClient).DownloadFile('%downloadUrl%', '%downloadFileName%') }"

REM 解压文件
echo 正在解压文件...
powershell -NonInteractive -command "& { Expand-Archive -Path '%downloadFileName%' -DestinationPath '%extractToDirectory%' }"

REM 清理临时文件
del "%downloadFileName%"
cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo =====--------------------------------------------- 10%%
echo 完成！文件已下载并解压到 "%extractToDirectory%" 目录下。
echo IP 资源更新完成。


REM 设置合并后的文件名和目录
set "mergeFileName=merged.txt"
set "sourceDirectory=ip\cloudflare-better-ip-main\cloudflare"

REM 删除旧的合并文件（如果存在）
if exist "%mergeFileName%" del "%mergeFileName%"

REM 合并所有 txt 文件到一个临时文件
for %%F in ("%sourceDirectory%\*.txt") do (
    type "%%F" >> "%mergeFileName%"
)

REM 清除空行并保存到新的结果文件
findstr /r /v "^$" "%mergeFileName%" > "%mergeFileName%.tmp"
move /y "%mergeFileName%.tmp" "%mergeFileName%"

REM 提示合并完成
echo 合并并清除空行完成。结果保存在 "%mergeFileName%" 文件中。

REM 设置目标文件夹路径
set "targetDirectory=ip\cloudflare-better-ip-main"

REM 确保目标文件夹存在
if not exist "%targetDirectory%" (
    echo 目标文件夹不存在，无需删除。
    pause
    exit /b
)

REM 删除目标文件夹及其所有内容
rd /s /q "%targetDirectory%"

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo ==========---------------------------------------- 20%%

REM 检查是否删除成功
if exist "%targetDirectory%" (
    echo 删除失败，请检查目标文件夹是否被占用。
) else (
    echo 删除成功，目标文件夹已被删除。
)

REM 设置输入文件和输出文件
set "inputFile=merged.txt"
set "outputFile=merged_nospace.txt"

REM 使用临时文件保存处理后的内容
set "tempFile=%outputFile%.tmp"

REM 清空输出文件（如果存在）
if exist "%tempFile%" del "%tempFile%"

REM 使用 PowerShell 将 merged.txt 文件中的内容去除所有空格，并保存到临时文件
powershell -command "Get-Content '%inputFile%' | ForEach-Object { $_ -replace ' ', '' } | Set-Content '%tempFile%'"

REM 将临时文件替换原始文件
move /y "%tempFile%" "%outputFile%"

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo ===============----------------------------------- 30%%

REM 输出处理完成的消息
echo merged.txt 文件中的空格已清除。
echo 处理后的结果保存在 "%outputFile%" 文件中。

REM 设置输入文件和输出文件
set "inputFile=merged_nospace.txt"
set "outputFile=merged_nospace_lower.txt"

REM 清空输出文件（如果存在）
if exist "%outputFile%" del "%outputFile%"

REM 使用 PowerShell 将 merged_nospace.txt 文件中的内容转换为小写字母，并保存到输出文件
powershell -command "Get-Content '%inputFile%' | ForEach-Object { $_.ToLower() } | Set-Content '%outputFile%'"

REM 输出处理完成的消息
echo merged_nospace.txt 文件中的大写字母已转换为小写字母。
echo 处理后的结果保存在 "%outputFile%" 文件中。

set "input_file=merged_nospace_lower.txt"
set "output_file=output.txt"

REM 将冒号替换为竖线，并将结果输出到临时文件
(for /f "delims=" %%i in (%input_file%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    echo !line::=^|!
    endlocal
)) > "%output_file%"

REM 删除原始文件
del "%input_file%"

REM 将临时文件重命名为原始文件名
ren "%output_file%" "%input_file%"

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo ====================------------------------------ 40%%
echo 替换完成！

setlocal enabledelayedexpansion

set "inputFile=merged_nospace_lower.txt"
set "outputFile=modified_merged.txt"

if exist "%outputFile%" del "%outputFile%"

for /f "usebackq delims=" %%a in ("%inputFile%") do (
    set "line=%%a"
    set "count=0"
    set "result="
    
    for %%b in ("!line:|=" "|!") do (
        set /a "count+=1"
        if !count! lss 5 (
            set "result=!result!%%~b"
        )
    )
    
    echo !result! >> "%outputFile%"
)

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo =========================------------------------- 50%%
echo 处理完成!

setlocal enabledelayedexpansion

set "inputFile=modified_merged.txt"
set "outputFile=output.txt"

if not exist "%inputFile%" (
    echo Input file "%inputFile%" not found.
    exit /b
)

del "%outputFile%" 2>NUL

for /F "usebackq tokens=*" %%a in ("%inputFile%") do (
    set "line=%%a"
    for /F "tokens=1,2,4 delims=|" %%b in ("!line!") do (
        echo %%b^|%%c^|%%d>> "%outputFile%"
    )
)

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo ==============================-------------------- 60%%
echo 开始进行去重处理,需要时间1分钟左右,请耐心等待

setlocal enabledelayedexpansion

REM 设置输入和输出文件名
set "inputFile=output.txt"
set "outputFile=output_deduplicated.txt"

REM 创建一个空的临时文件用于保存去重后的内容
set "tempFile=%TEMP%\tempfile_%RANDOM%.txt"
type nul > "%tempFile%"

REM 逐行读取输入文件的内容
for /f "delims=" %%i in ('type "%inputFile%"') do (
    REM 检查当前行是否已经存在于临时文件中，若不存在则追加到临时文件
    findstr /x /c:"%%i" "%tempFile%" >nul || echo %%i>>"%tempFile%"
)

REM 将临时文件的内容复制到输出文件
copy /y "%tempFile%" "%outputFile%" >nul

REM 删除临时文件
del "%tempFile%"

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo ===================================--------------- 70%%
echo 去重后的内容已保存到 %outputFile%

setlocal enabledelayedexpansion

REM 清除文件内的空格
(for /f "tokens=*" %%a in (output_deduplicated.txt) do (
    set "line=%%a"
    echo(!line: =!
)) > temp.txt

REM 处理每行内容并写入文件
for /f "tokens=1-3 delims=|" %%a in (temp.txt) do (
    set "ip=%%a"
    set "port=%%b"
    set "area=%%c"
    
    set "filename=ip\!area!-1-!port!.txt"
    
    if not exist "!filename!" (
        echo !ip! > "!filename!"
    ) else (
        echo !ip! >> "!filename!"
    )
)

REM 删除临时文件
del temp.txt

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo ========================================---------- 80%%
echo 任务完成！开始执行临时文件清理工作！

echo 检查并删除 merged.txt
if exist merged.txt (
    echo Deleting merged.txt
    del merged.txt
) else (
    echo merged.txt not found, skipping deletion.
)

echo 检查并删除 merged_nospace.txt
if exist merged_nospace.txt (
    echo Deleting merged_nospace.txt
    del merged_nospace.txt
) else (
    echo merged_nospace.txt not found, skipping deletion.
)

echo 检查并删除 merged_nospace_lower.txt
if exist merged_nospace_lower.txt (
    echo Deleting merged_nospace_lower.txt
    del merged_nospace_lower.txt
) else (
    echo merged_nospace_lower.txt not found, skipping deletion.
)

echo 检查并删除 modified_merged.txt
if exist modified_merged.txt (
    echo Deleting modified_merged.txt
    del modified_merged.txt
) else (
    echo modified_merged.txt not found, skipping deletion.
)

echo 检查并删除 output.txt
if exist output.txt (
    echo Deleting output.txt
    del output.txt
) else (
    echo output.txt not found, skipping deletion.
)

echo 检查并删除 output_deduplicated.txt
if exist output_deduplicated.txt (
    echo Deleting output_deduplicated.txt
    del output_deduplicated.txt
) else (
    echo output_deduplicated.txt not found, skipping deletion.
)

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo ================================================== 100%%
echo 更新IPDate_Plus库更新完成
exit /b
REM 目前脚本只执行到这里，如果需要去重的可以将上一行exit /b给注释掉，但是这会影响到自动化。如果不需要去重别改动脚本

echo 对现有IP库进行去重处理预计需要时间10~20分钟
REM pause

	REM 设置默认值为 "N"
	set "updateChoice=N"

	REM 提示用户是否更新 IP 资源
	set /p "updateChoice=是否对 IP 资源进行去重？(Y/N，默认为 N)："

	REM 将用户输入转换为大写，方便后续比较
	set "updateChoice=%updateChoice:~0,1%"
	set "updateChoice=%updateChoice:~0,1%"

	REM 如果用户选择 "Y" 或 "y"，则运行 去重
	if /i "%updateChoice%"=="Y" (
		echo 用户选择去重 IP 资源。
		call :qvchong
	) else (
		echo 用户选择不去重 IP 资源。
		
	)

exit /b
:qvchong
setlocal enabledelayedexpansion
rem 设置当前目录为工作目录
cd /d "%~dp0"

rem 遍历当前目录下的ip文件夹内的所有txt文件
for /r .\ip %%F in (*.txt) do (
    echo Processing: %%F
    set "output_file=%%~dpnF.tmp"
    (for /f "usebackq delims=" %%L in ("%%F") do (
        set "line=%%L"
        setlocal enabledelayedexpansion
        set "line=!line: =!"
        echo(!line!>> "!output_file!"
		REM 将内容写入临时文件
        endlocal
    )) && (
        move /y "!output_file!" "%%F"
		REM 将临时文件重命名为源文件
        echo Done processing: %%F
    ) || (
        echo Error processing: %%F
    )
)

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo 正在对现有IP库进行去重处理预计需要时间10~20分钟，请耐心等待~
setlocal enabledelayedexpansion

for %%F in (ip\*.txt) do (
    echo Processing %%F
    type nul > "%%F.tmp"
    for /f "usebackq delims=" %%L in ("%%F") do (
        findstr /x /c:"%%L" "%%F.tmp" > nul || echo %%L>> "%%F.tmp"
    )
    move /y "%%F.tmp" "%%F" > nul
)

cls
echo ╔═══════════════════════════知识共享许可协议═════════════════════════════╗
echo ║                                                                        ║
echo ║     欢迎运行CloudflareST第三方IP自动测速反代脚本                       ║
echo ║     提问建议请留言http://www.cmliu.net                                 ║
echo ║     署名-非商业性使用-脚本使用者自行承担使用后果。                     ║
echo ║     IP来源自https://github.com/hello-earth/cloudflare-better-ip        ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo 对现有IP库去重处理完成
pause
exit /b
