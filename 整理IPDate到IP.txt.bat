@echo off
setlocal enabledelayedexpansion

set "outputFile=ip.txt"

(for %%F in (ip\*-1-443.txt) do (
    if exist "%%F" (
        type "%%F"
        echo.
    ) else (
        echo 文件 "%%F" 不存在。
    )
)) > "%outputFile%"

(
    for /f "delims=" %%a in ('type "%outputFile%" ^& break ^> "%outputFile%"'
    ) do (
        set "line=%%a"
        if defined line (
            echo !line!
        )
    )
) > "%outputFile%.temp"

move /y "%outputFile%.temp" "%outputFile%"

echo 内容已合并到 %outputFile% 
echo 开始进行去重处理,需要时间1分钟左右,请耐心等待

REM pause

REM 创建一个空的临时文件用于保存去重后的内容
set "tempFile=%TEMP%\tempfile_%RANDOM%.txt"
type nul > "%tempFile%"

REM 逐行读取输入文件的内容
for /f "delims=" %%i in ('type "%outputFile%"') do (
    REM 检查当前行是否已经存在于临时文件中，若不存在则追加到临时文件
    findstr /x /c:"%%i" "%tempFile%" >nul || echo %%i>>"%tempFile%"
)

REM 将临时文件的内容复制到输出文件
copy /y "%tempFile%" "%outputFile%" >nul

REM 删除临时文件
del "%tempFile%"

REM pause
