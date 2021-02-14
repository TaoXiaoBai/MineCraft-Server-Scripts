@ECHO OFF
::::
:::: Minecraft-Forge 服务器安装/启动器脚本
:::: 由 "All The Mods"团队创建
::::
:::: 这个脚本将设置并启动 Minecraft服务器
:::: *** 本文件不打算修改，请使用 "settings.cfg" ***。
::::
:::: 寻求"All The Mods"团队帮助（或更多细节）。
::::    Github: https://github.com/AllTheMods/Server-Scripts
::::    Discord: https://discord.gg/FdFDVWb
::::    汉化 By:TaoXiaoBai 
::::

:::: *** 此文件不打算修改，请使用 "settings.cfg" ***。

::================================================================================::
::*** LICENSE ***::

:: The only reason we included a license is because we wanted it to be easier 
:: for more people to use/share this. Some places (i.e. Curse) need some form of 
:: "official" notice allowing content to be used. Since we were making a license 
:: anyway, we thought it would be nice to add an attribution clause so others 
:: didn't try to claim our work as their own. The result is this custom license 
:: based on a combination of the MIT license and a couple parts from Vaskii's 
:: Botania/Psi license:

	:: Copyright (c) 2017 All The Mods Team

	:: Permission is hereby granted, free of charge, to any person obtaining a copy
	:: of this software and associated documentation files (the "Software"), to deal
	:: in the Software without restriction, including without limitation the rights
	:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	:: copies of the Software, and to permit persons to whom the Software is
	:: furnished to do so, subject to the following conditions:

	:: You must give appropriate credit to the "All The Mods Team" as original 
	:: creators for any parts of this Software being used. A link back to original 
	:: content is optional but would be greatly appreciated. 

	:: It is forbidden to charge for access to the distribution of this Software or 
	:: gain money through it. This includes any type of inline advertisement, such 
	:: as url shorteners (adf.ly or otherwise) or ads. This also includes 
	:: restricting any amount of access behind a paywall. Special permission is 
	:: given to allow this Software to be bundled or distributed with projects on 
	:: Curse.com, CurseForge.com or their related sub-domains and subsidiaries.

	:: Derivative works must be open source (have its source visible and allow for 
	:: redistribution and modification).

	:: The above copyright notice and conditions must be included in all copies or 
	:: substantial portions of the Software, including derivative works and 
	:: re-licensing thereof. 

::================================================================================::
::*** DISCLAIMERS ***::

	:: "All The Mods Team" is not affiliated with "Mojang," "Oracle," 
	:: "Curse," "Twitch," "Sponge," "Forge" or any other entity (or entity owning a 
	:: referenced product) potentially mentioned in this document or relevant source 
	:: code for this Software. The use of their names and/or trademarks is strictly 
	:: circumstantial and assumed fair-use. All credit for their respective works, 
	:: software, branding, copyrights and/or trademarks belongs entirely to them as 
	:: original owners/licensers.

	:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	:: SOFTWARE.

:::: *** THIS FILE NOT INTENDED TO BE EDITED, USE "settings.cfg" INSTEAD ***

SETLOCAL
REM Internal Scripty stuff
REM Define system root so we can run CORRECT version of things (like FIND)
SET MC_SYS32=%SYSTEMROOT%\SYSTEM32
REM default an error code in case error block is ran without this var being defined first
SET MC_SERVER_ERROR_REASON=Unspecified
REM this is a temp variable to use for intermidiate calculations and such
SET MC_SERVER_TMP_FLAG=0
REM this is the var to keep track of sequential crashes
SET MC_SERVER_CRASH_COUNTER=1
REM set "crash time" to initial script start 
SET MC_SERVER_CRASH_YYYYMMDD=%date:~10,4%%date:~4,2%%date:~7,2%
SET MC_SERVER_CRASH_HHMMSS=%time:~0,2%%time:~3,2%%time:~6,2%

REM Create log FOLDER if it doesn't exist
IF NOT EXIST "%~dp0logs\" (MKDIR logs && echo created non-existent "logs" folder)

REM delete log if already exists to start a fresh one
IF EXIST "%~dp0logs\serverstart.log" DEL /F /Q "%~dp0logs\serverstart.log"
ECHO. 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO. 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO. 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO ----------------------------------------------------------------- 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO INFO: batch启动时间是 %MC_SERVER_CRASH_YYYYMMDD%:%MC_SERVER_CRASH_HHMMSS% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO ----------------------------------------------------------------- 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO. 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: Current Dir is %CD% -- trying to change to %~dp0 1>>  "%~dp0logs\serverstart.log" 2>&1
CD "%~dp0" 1>>  "%~dp0logs\serverstart.log" 2>&1

:BEGIN
CLS
COLOR 3F

REM Check for config file
ECHO INFO: 正在检查settings.cfg是否存在 1>> "%~dp0logs\serverstart.log" 2>&1
IF NOT EXIST "%~dp0settings.cfg" (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Not_Found
	GOTO ERROR
)

ECHO DEBUG: 找到 settings.cfg，下面为记录全部内容: 1>>  "%~dp0logs\serverstart.log" 2>&1
>nul COPY "%~dp0logs\serverstart.log"+"%~dp0settings.cfg" "%~dp0logs\serverstart.log"
ECHO. 1>>  "%~dp0logs\serverstart.log" 2>&1

>nul %MC_SYS32%\FIND.EXE /I "MAX_RAM=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:MAX_RAM
	GOTO ERROR
	)

>nul %MC_SYS32%\FIND.EXE /I "JAVA_ARGS=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:JAVA_ARGS
	GOTO ERROR
	)

>nul %MC_SYS32%\FIND.EXE /I "CRASH_COUNT=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:CRASH_COUNT
	GOTO ERROR
	)

>nul %MC_SYS32%\FIND.EXE /I "CRASH_TIMER=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:CRASH_TIMER
	GOTO ERROR
	)

>nul %MC_SYS32%\FIND.EXE /I "RUN_FROM_BAD_FOLDER=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:RUN_FROM_BAD_FOLDER
	GOTO ERROR
	)

>nul %MC_SYS32%\FIND.EXE /I "IGNORE_OFFLINE=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:IGNORE_OFFLINE
	GOTO ERROR
	)	

>nul %MC_SYS32%\FIND.EXE /I "IGNORE_JAVA_CHECK=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:IGNORE_JAVA_CHECK
	GOTO ERROR
	)	

>nul %MC_SYS32%\FIND.EXE /I "MCVER=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:MCVER
	GOTO ERROR
	)	

>nul %MC_SYS32%\FIND.EXE /I "FORGEVER=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:FORGEVER
	GOTO ERROR
	)	

>nul %MC_SYS32%\FIND.EXE /I "FORGEURL=" "%~dp0settings.cfg" || (
	SET MC_SERVER_ERROR_REASON=Settings.cfg_Error:FORGEURL
	GOTO ERROR
	)		

REM  LOAD Settings from config
ECHO INFO: 从settings.cfg加载选项 1>>  "%~dp0logs\serverstart.log" 2>&1 
for /F "delims=; tokens=1 eol=;" %%A in (settings.cfg) DO (
	REM Only process the line if it contains an "equals" sign
	ECHO.%%A | findstr /C:"=">nul && (
		CALL SET %%A
	) || (
		REM Skipping Line without equals (blank or comments only)
	)
)
	REM Old way to parse settings--> broke if args had an "equals" (=) character
	REM for /f "delims==; tokens=1,2 eol=;" %%G in (settings.cfg) do set %%G=%%H 

REM Define Xms (min heap) as Floor(MAX_RAM / 2)
SET MC_SERVER_TMP_FLAG=
SET /A "MC_SERVER_TMP_FLAG=%MAX_RAM:~0,-1%/2"
FOR /f "tokens=1 delims=." %%a  in ("%MC_SERVER_TMP_FLAG%") DO (SET MC_SERVER_TMP_FLAG=%%a)
IF %MC_SERVER_TMP_FLAG% LSS 1 (SET MC_SERVER_TMP_FLAG=1)

REM Set some placeholder defaults (failsafe if settings.cfg is old version or corrupt somehow
SET MC_SERVER_MAX_RAM=5G
SET MC_SERVER_JVM_ARGS=-Xmx%MC_SERVER_MAX_RAM%
SET MC_SERVER_MAX_CRASH=5
SET MC_SERVER_CRASH_TIMER=600
SET MC_SERVER_RUN_FROM_BAD_FOLDER=0
SET MC_SERVER_IGNORE_OFFLINE=0
SET MC_SERVER_IGNORE_JAVA=0
SET MC_SERVER_MCVER=1.12.2
SET MC_SERVER_FORGEVER=14.23.2.2625
SET MC_SERVER_FORGEURL=DISABLE
SET MC_SERVER_SPONGE=0
SET MC_SERVER_HIGH_PRIORITY=0
SET MC_SERVER_PACKNAME=PLACEHOLDER

REM Re-map imported vars (from settings.cfg) into script-standard variables
SET MC_SERVER_MAX_RAM=%MAX_RAM%
SET MC_SERVER_JVM_ARGS=-Xmx%MC_SERVER_MAX_RAM% -Xms%MC_SERVER_TMP_FLAG%%MC_SERVER_MAX_RAM:~-1% %JAVA_ARGS%
SET MC_SERVER_MAX_CRASH=%CRASH_COUNT%
SET MC_SERVER_CRASH_TIMER=%CRASH_TIMER%
SET MC_SERVER_RUN_FROM_BAD_FOLDER=%RUN_FROM_BAD_FOLDER%
SET MC_SERVER_IGNORE_OFFLINE=%IGNORE_OFFLINE%
SET MC_SERVER_IGNORE_JAVA=%IGNORE_JAVA_CHECK%
SET MC_SERVER_MCVER=%MCVER%
SET MC_SERVER_FORGEVER=%FORGEVER%
SET MC_SERVER_FORGEURL=%FORGEURL%
SET MC_SERVER_SPONGE=%USE_SPONGE%
SET MC_SERVER_HIGH_PRIORITY=%HIGH_CPU_PRIORITY%
SET MC_SERVER_PACKNAME=%MODPACK_NAME%

REM Cleanup imported vars after being remapped
SET MAX_RAM=
SET FORGE_JAR=
SET JAVA_ARGS=
SET CRASH_COUNT=
SET CRASH_TIMER=
SET RUN_FROM_BAD_FOLDER=
SET IGNORE_OFFLINE=
SET MCVER=
SET FORGEVER=
SET FORGEURL=
SET USE_SPONGE=
SET HIGH_CPU_PRIORITY=
SET MODPACK_NAME=
SET MC_SERVER_TMP_FLAG=

REM Get forge shorthand version number
SET MC_SERVER_FORGESHORT=%MC_SERVER_FORGEVER:~-4%

TITLE %MC_SERVER_PACKNAME% 服务器启动脚本
ECHO.
ECHO *** 正在加载 %MC_SERVER_PACKNAME%  ***
ECHO 运行 Forge %MC_SERVER_FORGESHORT% 为 Minecraft %MC_SERVER_MCVER%。
TIMEOUT 1 >nul
ECHO.
ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO    Minecraft-Forge 服务器 安装/启动 脚本
ECHO    (由 "All The Mods" 团队制作)
ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO.
ECHO 本bat用于启动 Minecraft Forge 服务器
ECHO.
ECHO 寻求帮助 (或更多详细信息);
ECHO    Github:   https://github.com/AllTheMods/Server-Scripts
ECHO    Discord:  https://discord.gg/FdFDVWb
ECHO.
ECHO.

ECHO DEBUG: Starting variable definitions: 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_MAX_RAM=%MC_SERVER_MAX_RAM% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGE_JAR=%MC_SERVER_FORGE_JAR% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_SPONGE_BOOT=%MC_SERVER_SPONGE_BOOT% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_JVM_ARGS=%MC_SERVER_JVM_ARGS% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_MAX_CRASH=%MC_SERVER_MAX_CRASH% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_CRASH_TIMER=%MC_SERVER_CRASH_TIMER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_IGNORE_OFFLINE=%MC_SERVER_IGNORE_OFFLINE% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_RUN_FROM_BAD_FOLDER=%MC_SERVER_RUN_FROM_BAD_FOLDER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_MCVER=%MC_SERVER_MCVER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGEVER=%MC_SERVER_FORGEVER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGESHORT=%MC_SERVER_FORGESHORT% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGEURL=%MC_SERVER_FORGEURL% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_SPONGE=%MC_SERVER_SPONGE% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_HIGH_PRIORITY=%MC_SERVER_HIGH_PRIORITY% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_PACKNAME=%MC_SERVER_PACKNAME% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_SPONGEURL=%MC_SERVER_SPONGEURL% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_SPONGEBOOTSTRAPURL=%MC_SERVER_SPONGEBOOTSTRAPURL% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_ERROR_REASON=%MC_SERVER_ERROR_REASON% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_TMP_FLAG=%MC_SERVER_TMP_FLAG% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_CRASH_COUNTER=%MC_SERVER_CRASH_COUNTER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_CRASH_YYYYMMDD=%MC_SERVER_CRASH_YYYYMMDD% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_CRASH_HHMMSS=%MC_SERVER_CRASH_HHMMSS% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: Current directory file listing: 1>>  "%~dp0logs\serverstart.log" 2>&1
DIR 1>>  "%~dp0logs\serverstart.log" 2>&1

REM Check for 64-bit OS, not needed since 64-bit java is checked
REM reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE | find /i "x86" || GOTO CHECKJAVA 1>> "%~dp0logs\serverstart.log" 2>&1

:CHECKJAVA
ECHO INFO: 正在检查Java安装...
ECHO DEBUG: JAVA version output (java -d64 -version): 1>>  "%~dp0logs\serverstart.log" 2>&1
java -d64 -version || GOTO JAVAERROR 1>>  "%~dp0logs\serverstart.log" 2>&1

java -d64 -version 2>&1 | %MC_SYS32%\FIND.EXE "1.8"  1>>  "%~dp0logs\serverstart.log" 2>&1
IF %ERRORLEVEL% EQU 0 (
	ECHO INFO: Found 64-bit Java 1.8 1>> "%~dp0logs\serverstart.log" 2>&1
	ECHO ...64-bit Java 1.8 found! 1>> "%~dp0logs\serverstart.log" 2>&1
	GOTO CHECKFOLDER
) ELSE (
    GOTO JAVAERROR
)

:JAVAERROR
IF NOT %MC_SERVER_IGNORE_JAVA% EQU 0 (
	ECHO WARN: 正在跳过对正确的Java安装/版本的验证...
	ECHO 如果未安装Java、太旧或不是64位，服务器可能无法正确启动/运行
	ECHO 警告：正在跳过Java安装的验证... 1>>  "%~dp0logs\serverstart.log" 2>&1
	GOTO CHECKFOLDER
)
COLOR CF
ECHO 错误：找不到已安装或位于路径中的64位Java 1.8 1>> "%~dp0logs\serverstart.log" 2>&1
SET MC_SERVER_ERROR_REASON="JavaVersionOrPathError"
CLS
ECHO.
ECHO 错误：找不到安装的有效Java版本
>nul TIMEOUT 1
ECHO 强烈推荐使用64位Java V1.8+ ，可以通过下方链接来查看最新的Java下载：
ECHO https://java.com/en/download/manual.jsp
ECHO.
>nul TIMEOUT 1
GOTO ERROR

:CHECKFOLDER
IF NOT %MC_SERVER_RUN_FROM_BAD_FOLDER% EQU 0 (
	ECHO 警告：正在 跳过检查 服务器目录是否位于可能有问题的位置...
	ECHO 警告：正在 跳过检查 服务器目录是否位于可能有问题的位置... 1>>  "%~dp0logs\serverstart.log" 2>&1
	GOTO CHECKONLINE
)
ECHO 正在检查当前文件夹是否有效...
ECHO 信息：正在检查当前文件夹是否有效... 1>>  "%~dp0logs\serverstart.log" 2>&1

REM Check if current directory is in ProgramFiles
IF NOT DEFINED ProgramFiles ( GOTO CHECKPROG86 )
ECHO.x%CD%x | %MC_SYS32%\FINDSTR.EXE /I /C:"%ProgramFiles%" >nul
REM ECHO Error Level: %ERRORLEVEL%
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=BadFolder-ProgramFiles;
	GOTO FOLDERERROR
)
ECHO.x%~dp0x | %MC_SYS32%\FINDSTR.EXE /I /C:"%ProgramFiles%" >nul
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=BadFolder-ProgramFiles;
	GOTO FOLDERERROR
)

:CHECKPROG86
IF NOT DEFINED ProgramFiles^(x86^) ( GOTO CHECKSYS )
ECHO.x%CD%x | %MC_SYS32%\FINDSTR.EXE /I /C:"%ProgramFiles(x86)%" >nul
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=BadFolder-ProgramFiles86;
	GOTO FOLDERERROR
)
ECHO.x%~dp0x | %MC_SYS32%\FINDSTR.EXE /I /C:"%ProgramFiles(x86)%" >nul
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=BadFolder-ProgramFiles86;
	GOTO FOLDERERROR
)

:CHECKSYS
REM Check if current directory is in SystemRoot
IF NOT DEFINED SystemRoot ( GOTO CHECKTEMP )
ECHO.x%CD%x | %MC_SYS32%\FINDSTR.EXE /I /C:"%SystemRoot%" >nul
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=BadFolder-System;
	GOTO FOLDERERROR
)
ECHO.x%~dp0x | %MC_SYS32%\FINDSTR.EXE /I /C:"%SystemRoot%" >nul
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=BadFolder-System;
	GOTO FOLDERERROR
)

:CHECKTEMP
REM Check if current directory is in TEMP
IF NOT DEFINED TEMP ( GOTO CHECKTMP )
ECHO.x%CD%x | %MC_SYS32%\FINDSTR.EXE /I /C:"%TEMP%" >nul
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=BadFolder-Temp;
	GOTO FOLDERERROR
)
ECHO.x%~dp0x | %MC_SYS32%\FINDSTR.EXE /I /C:"%TEMP%" >nul
IF %ERRORLEVEL% EQU 0 (
	SET MC_SERVER_ERROR_REASON=BadFolder-Temp;
	GOTO FOLDERERROR
)

:CHECKTMP
IF NOT DEFINED TMP ( GOTO CHECKONLINE )
	ECHO.x%CD%x | %MC_SYS32%\FINDSTR.EXE /I /C:"%TMP%" >nul
	IF %ERRORLEVEL% EQU 0 (
		SET MC_SERVER_ERROR_REASON=BadFolder-Temp;
		GOTO FOLDERERROR
	)
	ECHO.x%~dp0x | %MC_SYS32%\FINDSTR.EXE /I /C:"%TMP%" >nul
	IF %ERRORLEVEL% EQU 0 (
		SET MC_SERVER_ERROR_REASON=BadFolder-Temp;
		GOTO FOLDERERROR
	)
)
GOTO CHECKONLINE

:FOLDERERROR
ECHO 警告：从 "Program Files"、“"emporary"或"System"文件夹运行可能会导致权限问题和数据丢失
ECHO 警告：如果您仍要执行此操作，则需要更改脚本，将MC_SERVER_RUN_FROM_BAD_Folder设置为 1
ECHO 警告：从 "Program Files"、“"emporary"或"System"文件夹运行可能会导致权限问题和数据丢失 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO 警告：如果您仍要执行此操作，则需要更改脚本，将MC_SERVER_RUN_FROM_BAD_Folder设置为 1 1>>  "%~dp0logs\serverstart.log" 2>&1
GOTO ERROR

:CHECKONLINE
IF NOT %MC_SERVER_IGNORE_OFFLINE% EQU 0 (
	ECHO 正在跳过Internet检查...
	ECHO WARN: 正在跳过Internet检查... 1>>  "%~dp0logs\serverstart.log" 2>&1
	GOTO CHECKFILES
)

ECHO 正在检查Internet连接...
ECHO 信息：正在检查基本Internet连接... 1>>  "%~dp0logs\serverstart.log" 2>&1

REM Try with Google DNS
%MC_SYS32%\PING.EXE -n 2 -w 1000 8.8.8.8 | %MC_SYS32%\FIND.EXE "TTL="  1>>  "%~dp0logs\serverstart.log" 2>&1
IF %ERRORLEVEL% EQU 0 (
    SET MC_SERVER_TMP_FLAG=0
	ECHO INFO: Ping of "8.8.8.8" Successfull 1>>  "%~dp0logs\serverstart.log" 2>&1
) ELSE (
    SET MC_SERVER_TMP_FLAG=1
	ECHO WARN: Ping of "8.8.8.8" Failed 1>>  "%~dp0logs\serverstart.log" 2>&1
)

REM If Google ping failed try one more time with L3 just in case
IF MC_SERVER_TMP_FLAG EQU 1 (
	%MC_SYS32%\PING.EXE -n 2 -w 1000 4.2.2.1 | %MC_SYS32%\FIND.EXE "TTL="  1>>  "%~dp0logs\serverstart.log" 2>&1
	IF %ERRORLEVEL% EQU 0 (
		SET MC_SERVER_TMP_FLAG=0
		INFO: Ping of "4.4.2.1" Successfull 1>>  "%~dp0logs\serverstart.log" 2>&1
	) ELSE (
		SET MC_SERVER_TMP_FLAG=1
		ECHO WARN: Ping of "4.4.2.1" Failed 1>>  "%~dp0logs\serverstart.log" 2>&1
	)
)

REM Possibly no internet connection...
IF MC_SERVER_TMP_FLAG EQU 1 (
	ECHO 错误：无法连接到Internet
	ECHO 错误：无法连接到Internet 1>>  "%~dp0logs\serverstart.log" 2>&1
	SET MC_SERVER_ERROR_REASON=NoInternetConnectivity
	GOTO ERROR
	)

:CHECKFILES
ECHO 正在检查forge/minecraft二进制文件...
ECHO INFO: 检查forge/minecraft二进制文件... 1>>  "%~dp0logs\serverstart.log" 2>&1

REM Check if forge is already installed
IF NOT EXIST "%~dp0*forge*%MC_SERVER_FORGEVER%*.jar" (
	ECHO 找不到 %MC_SERVER_FORGEVER% 二进制文件，正在重新安装。
	ECHO INFO: 找不到 %MC_SERVER_FORGEVER% 二进制文件，正在重新安装。 1>>  "%~dp0logs\serverstart.log" 2>&1
	GOTO INSTALLSTART
)

REM Check if Minecraft JAR is already downloaded
IF NOT EXIST "%~dp0*minecraft_server.%MC_SERVER_MCVER%.jar" (
	ECHO 找不到Minecraft二进制文件，正在重新安装Forge...
	ECHO INFO: 找不到Minecraft二进制文件，正在重新安装Forge...  1>>  "%~dp0logs\serverstart.log" 2>&1
	GOTO INSTALLSTART
)

REM Check if Libraries are already downloaded
IF NOT EXIST "%~dp0libraries" (
	ECHO 找不到Libraries文件夹，正在重新安装Forge...
	ECHO INFO: 找不到Libraries文件夹，正在重新安装Forge... 1>>  "%~dp0logs\serverstart.log" 2>&1
	GOTO INSTALLSTART
)

REM Sponge?
IF %MC_SERVER_SPONGE% EQU 1 (
	ECHO.
	ECHO. **** WARNING ****
	ECHO SPONGE 已被启用，你可以通过 settings.cfg来决定是否开启
	ECHO 使用 SPONGE 来运行这个modpack是实验性的，可能会导致意想不到的问题
	ECHO **** 使用SPONGE，风险自负 ****
	ECHO 已在 settings.cfg 中启用了SPONGE-这是实验性的，可能会导致意外的问题，请自行承担风险  1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO.
	REM create "/mods/" folder if it doesn't exist
	IF NOT EXIST "%~dp0mods" (
		ECHO 找不到MODS文件夹，正在创建...
		ECHO INFO: 找不到MODS文件夹，正在创建... 1>>  "%~dp0logs\serverstart.log" 2>&1
		MKDIR "%~dp0mods" 1>>  "%~dp0logs\serverstart.log" 2>&1
	)
	REM Check for spongeforge jar in /mods/
	IF NOT EXIST "%~dp0mods/*spongeforge*%MC_SERVER_MCVER%*.jar" (
		ECHO 在 "mods" 文件夹中找不到的SpongeForge JAR...
		ECHO INFO: 在 "mods" 文件夹中找不到的SpongeForge JAR...  1>>  "%~dp0logs\serverstart.log" 2>&1
		GOTO DOWNLOADSPONGE
	)
	REM Check for spongeforge bootstrapper
	IF NOT EXIST "%~dp0*sponge*bootstrap*.jar" (
		ECHO 未找到SpongeForge Bootstrap加载器......
		ECHO INFO: 未找到SpongeForge Bootstrap加载器 1>>  "%~dp0logs\serverstart.log" 2>&1
		GOTO DOWNLOADSPONGE
	)	
)

REM set absolute paths for binary JARs
(FOR /f "usebackq tokens=* delims=*" %%x in (`dir ^"*forge*%MC_SERVER_FORGEVER%*.jar^" /B /O:-D`) DO SET "MC_SERVER_FORGE_JAR=%%x" & GOTO CHECKFILES1) 1>> "%~dp0logs\serverstart.log" 2>&1

:CHECKFILES1
(FOR /f "usebackq tokens=* delims=*" %%x in (`dir ^"*sponge*bootstrap*.jar^" /B /O:-D`) DO SET "MC_SERVER_SPONGE_BOOT=%%x" & GOTO CHECKFILES2) 1>> "%~dp0logs\serverstart.log" 2>&1

:CHECKFILES2
REM Delete duplicate binary JARs
ECHO DEBUG: MC_SERVER_SPONGE_BOOT=%MC_SERVER_SPONGE_BOOT% 1>> "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGE_JAR=%MC_SERVER_FORGE_JAR% 1>> "%~dp0logs\serverstart.log" 2>&1
ATTRIB +R "%MC_SERVER_SPONGE_BOOT%"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Sponge Jar present to read-only 1>> "%~dp0logs\serverstart.log" 2>&1
ATTRIB +R "%MC_SERVER_FORGE_JAR%"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Forge Jar present to read-only 1>> "%~dp0logs\serverstart.log" 2>&1
DEL "%~dp0*forge*.jar" /A:-R  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Sponge Jars present to delete 1>> "%~dp0logs\serverstart.log" 2>&1
DEL "%~dp0*sponge*bootstrap*.jar" /A:-R  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Forge Jars present to delete 1>> "%~dp0logs\serverstart.log" 2>&1
ATTRIB -R "%MC_SERVER_SPONGE_BOOT%"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Sponge Jar present to UN-read-only 1>> "%~dp0logs\serverstart.log" 2>&1
ATTRIB -R "%MC_SERVER_FORGE_JAR%"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Forge Jar present to UN-read-only 1>> "%~dp0logs\serverstart.log" 2>&1

:STARTSERVER
CLS 
IF /i "%1"=="install" (GOTO INSTALLCOMPLETE)
TITLE %MC_SERVER_PACKNAME% 服务器正在运行
ECHO.
ECHO.
ECHO 启动 %MC_SERVER_PACKNAME% 服务器...
ECHO INFO: 服务器启动中... 1>>  "%~dp0logs\serverstart.log" 2>&1
COLOR 07

REM Batch will wait here indefinitely while MC server is running
IF %MC_SERVER_SPONGE% EQU 1 (
	ECHO DEBUG: Attempting to execute [ java %MC_SERVER_JVM_ARGS% -jar "%~dp0%MC_SERVER_SPONGE_BOOT%" nogui ]
	ECHO DEBUG: Attempting to execute [ java %MC_SERVER_JVM_ARGS% -jar "%~dp0%MC_SERVER_SPONGE_BOOT%" nogui ] 1>> "%~dp0logs\serverstart.log" 2>&1
	COLOR 
	IF %MC_SERVER_HIGH_PRIORITY% EQU 1 (
		START /B /I /WAIT /HIGH java %MC_SERVER_JVM_ARGS% -jar "%~dp0%MC_SERVER_SPONGE_BOOT%" nogui
	) ELSE (
		java %MC_SERVER_JVM_ARGS% -jar "%~dp0%MC_SERVER_SPONGE_BOOT%" nogui
	)
) ELSE (
	ECHO DEBUG: Disabling any spongeforge jar in \mods\ because USE_SPONGE is disabled in settings.cfg 1>> "%~dp0logs\serverstart.log" 2>&1
	(FOR /f "tokens=* delims=*" %%x in ('dir "%~dp0mods\*spongeforge*.jar" /B /O:-D') DO MOVE /Y "%~dp0mods\%%x" "%%x.disabled") 1>> "%~dp0logs\serverstart.log" 2>&1
	ECHO DEBUG: Attempting to execute [ java %MC_SERVER_JVM_ARGS% -jar "%~dp0%MC_SERVER_FORGE_JAR%" nogui ]
	ECHO DEBUG: Attempting to execute [ java %MC_SERVER_JVM_ARGS% -jar "%~dp0%MC_SERVER_FORGE_JAR%" nogui ] 1>> "%~dp0logs\serverstart.log" 2>&1
	COLOR 
	IF %MC_SERVER_HIGH_PRIORITY% EQU 1 (
		START /B /I /WAIT /HIGH java %MC_SERVER_JVM_ARGS% -jar "%~dp0%MC_SERVER_FORGE_JAR%" nogui
	) ELSE (
		java %MC_SERVER_JVM_ARGS% -jar "%~dp0%MC_SERVER_FORGE_JAR%" nogui
	)
)

REM 如果服务器退出或崩溃，请重新启动...
REM CLS
ECHO.
ECHO WARN: %MC_SERVER_PACKNAME% 服务器已停止运行 (可能已崩溃)......
GOTO RESTARTER

:INSTALLSTART
COLOR 5F
TITLE 为 %MC_SERVER_PACKNAME% 服务器版本安装Forge/Minecraft
ECHO 在安装forge/minecraft之前清除旧文件...
ECHO INFO: 在安装forge/minecraft之前清除旧文件... 1>>  "%~dp0logs\serverstart.log" 2>&1

REM Just in case there's anything pending or dupe-named before starting...
%MC_SYS32%\bitsadmin.exe /reset 1>>  "%~dp0logs\serverstart.log" 2>&1

(FOR /f "tokens=* delims=*" %%x in ('dir "%~dp0*forge*%MC_SERVER_MCVER%*%MC_SERVER_FORGEVER%*installer.jar" /B /O:-D') DO SET "MC_SERVER_TMP_FLAG=%%x" & GOTO INSTALL1) 1>> "%~dp0logs\serverstart.log" 2>&1

:INSTALL1
REM Delete old/duplicate installers
ECHO: DEBUG: MC_SERVER_TMP_FLAG=%MC_SERVER_TMP_FLAG% 1>> "%~dp0logs\serverstart.log" 2>&1
ATTRIB +R "%MC_SERVER_TMP_FLAG%"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Forge Installer present to read-only 1>> "%~dp0logs\serverstart.log" 2>&1
DEL "%~dp0*forge*installer*.jar*" /A:-R  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Forge Installers present to delete 1>> "%~dp0logs\serverstart.log" 2>&1
ATTRIB -R "%MC_SERVER_TMP_FLAG%"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Forge Installer present to UN-read-only 1>> "%~dp0logs\serverstart.log" 2>&1
SET MC_SERVER_TMP_FLAG= 1>> "%~dp0logs\serverstart.log" 2>&1

REM Check for existing/included forge-installer and run it instead of downloading
IF EXIST "%~dp0forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar" (
	ECHO.
	ECHO.
	ECHO 已找到现有的forge安装程序...
	ECHO 默认使用此安装程序，而不是重新下载
	GOTO RUNINSTALLER
)

IF NOT %MC_SERVER_IGNORE_OFFLINE% EQU 0 (
	ECHO 正在跳过 Forge 服务器在线检查...
	ECHO WARN: 正在跳过 Forge 服务器在线检查... 1>>  "%~dp0logs\serverstart.log" 2>&1
	GOTO FORGEFILEPREP
)

REM Ping minecraftforge before attempting download
%MC_SYS32%\PING.EXE -n 2 -w 1000 minecraftforge.net | %MC_SYS32%\FIND.EXE "TTL="  1>> "%~dp0logs\serverstart.log" 2>&1
IF %ERRORLEVEL% EQU 0 (
	ECHO INFO: Ping of "minecraftforge.net" Successfull 1>>  "%~dp0logs\serverstart.log" 2>&1
) ELSE (
	ECHO ERROR: 无法访问 minecraftforge.net！可能是 防火墙 或 internet 问题?
	ECHO ERROR: 无法访问 minecraftforge.net 1>>  "%~dp0logs\serverstart.log" 2>&1
	SET MC_SERVER_ERROR_REASON=NoInternetConnectivityMinecraftForgeNet
	GOTO ERROR
)

:FORGEFILEPREP
DEL /F /Q "%~dp0*forge*.html"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No forge-index to delete 1>>  "%~dp0logs\serverstart.log" 2>&1
DEL /F /Q "%~dp0*forge*"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No forge-universal to delete 1>>  "%~dp0logs\serverstart.log" 2>&1
DEL /F /Q "%~dp0*tmp-forgeinstaller.jar" 1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No forge-installer to delete 1>> "%~dp0logs\serverstart.log" 2>&1
DEL /F /Q "%~dp0*minecraft*server*%MC_SERVER_MCVER%*.jar" 1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No minecraft binary to delete 1>> "%~dp0logs\serverstart.log" 2>&1
RMDIR /S /Q "%~dp0libraries" 1>>  "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No Libraries folder to delete 1>> "%~dp0logs\serverstart.log" 2>&1

ECHO.
ECHO.
ECHO 正在下载Forge (第1步，共2步) 这可能需要几分钟，请耐心等待...
REM Check if direct forge URL is specified in config
IF NOT %MC_SERVER_FORGEURL%==DISABLE (
	ECHO 正在尝试从 "%MC_SERVER_FORGEURL% 下载... 这可能需要一些时间，请稍候." 
	GOTO DOWNLOADINSTALLER
)

SET MC_SERVER_TMP_FLAG=0

:FETCHHTML
REM Download Forge Download Index HTML to parse the URL for the direct download
ECHO INFO: Fetching index html from forge ^( https://files.minecraftforge.net/maven/net/minecraftforge/forge/index_%MC_SERVER_MCVER%.html ^) 1>>  "%~dp0logs\serverstart.log" 2>&1
%MC_SYS32%\bitsadmin.exe /rawreturn /nowrap /transfer dlforgehtml /download /priority FOREGROUND "https://files.minecraftforge.net/maven/net/minecraftforge/forge/index_%MC_SERVER_MCVER%.html" "%~dp0forge-%MC_SERVER_MCVER%.html"  1>> "%~dp0logs\serverstart.log" 2>&1

IF NOT EXIST "%~dp0forge-%MC_SERVER_MCVER%.html" (
	IF "%MC_SERVER_TMP_FLAG%"=="0" (
		ECHO 出了点问题，再试一次...
		SET MC_SERVER_TMP_FLAG=1
		GOTO FETCHHTML
	) ELSE (
		SET MC_SERVER_ERROR_REASON=ForgeIndexNotFound
		GOTO ERROR
	)
)

REM Simple search for matching text to make sure we got the correct webpage/html (and not a 404, for example)
REM ECHO DEBUG: Checking simple pattern match for forge ver to validate HTML... 1>>  "%~dp0logs\serverstart.log" 2>&1
REM FIND /I "%MC_SERVER_FORGEVER%" forge-%MC_SERVER_MCVER%.html 1>> "%~dp0logs\serverstart.log" 2>&1 || (
REM 	IF %MC_SERVER_TMP_FLAG% LEQ 0 (
REM 		ECHO Something wrong with Forge download part 1 of 2
REM 		ECHO Something wrong with Forge download part 1 of 2 1>>  "%~dp0logs\serverstart.log" 2>&1
REM 		SET MC_SERVER_TMP_FLAG=1
REM 		DEL /F /Q "%~dp0*forge-index.html"  1>> "%~dp0logs\serverstart.log" 2>&1 || ECHO INFO: No forge-index to delete 1>>  "%~dp0logs\serverstart.log" 2>&1
REM 		GOTO FETCHHTML
REM 	) ELSE (
REM 		ECHO HTML Download failed a second time... stopping. 
REM 		ECHO ERROR: HTML Download failed a second time... stopping. 1>>  "%~dp0logs\serverstart.log" 2>&1
REM 		SET MC_SERVER_ERROR_REASON=ForgeDownloadURLNotFound
REM 		GOTO ERROR
REM 	)
REM )

REM More complex wannabe-regex (aka magic)
FOR /f tokens^=^5^ delims^=^=^<^>^" %%G in ('%MC_SYS32%\FINDSTR.EXE /ir "https://files.minecraftforge.net/maven/net/minecraftforge/forge/%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%/forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar" "%~dp0forge-%MC_SERVER_MCVER%.html"') DO SET MC_SERVER_FORGEURL=%%G & GOTO FETCHHTML1

:FETCHHTML1
IF "%MC_SERVER_FORGEURL%"=="%MC_SERVER_FORGEURL:installer.jar=%" (
	IF "%MC_SERVER_TMP_FLAG%"=="0" (
		ECHO 有什么东西出了点问题，请再试一次...
		SET MC_SERVER_TMP_FLAG=1
		GOTO FETCHHTML
	) ELSE (
		SET MC_SERVER_ERROR_REASON=ForgeDownloadURLNotFound
		GOTO ERROR
	)
) 

ECHO 正在下载FORGE（第2步，共2步）。这可能需要几分钟，请耐心等待....
SET MC_SERVER_TMP_FLAG=0

:DOWNLOADINSTALLER
REM 尝试将安装程序下载到临时下载区
ECHO DEBUG: Attempting to download "%MC_SERVER_FORGEURL%" 1>> "%~dp0logs\serverstart.log" 2>&1
%MC_SYS32%\bitsadmin.exe /rawreturn /nowrap /transfer dlforgeinstaller /download /priority FOREGROUND %MC_SERVER_FORGEURL% "%~dp0tmp-forgeinstaller.jar"  1>>  "%~dp0logs\serverstart.log" 2>&1

REM 检查是否已下载临时下载安装程序
IF NOT EXIST "%~dp0tmp-forgeinstaller.jar" (
IF "%MC_SERVER_TMP_FLAG%"=="0" (
		ECHO 下载 Forge Installer 第2步时出现问题，正在重试... 
		ECHO 下载 Forge Installer 第2步时出现问题，正在重试...  1>>  "%~dp0logs\serverstart.log" 2>&1
		SET MC_SERVER_TMP_FLAG=1
		GOTO DOWNLOADINSTALLER
	) ELSE (
		ECHO FORGE Installer下载第二次失败...正在停止
		ECHO 错误：FORGE Installer下载第二次失败...正在停止 1>>  "%~dp0logs\serverstart.log" 2>&1
		SET MC_SERVER_ERROR_REASON=ForgeInstallerDownloadFailed
		GOTO ERROR
	)
)

REM 将临时安装程序改名为正确的安装程序，替换掉已经存在的安装程序
DEL /F /Q "%~dp0forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar" 1>>  "%~dp0logs\serverstart.log" 2>&1
MOVE /Y "%~dp0tmp-forgeinstaller.jar" "forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar"  1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO 下载完成

:RUNINSTALLER
ECHO.
ECHO 正在安装Forge，请稍候...
ECHO INFO: 立即开始Forge安装，详细信息如下: 1>>  "%~dp0logs\serverstart.log" 2>&1
java -jar "%~dp0forge-%MC_SERVER_MCVER%-%MC_SERVER_FORGEVER%-installer.jar" --installServer 1>>  "%~dp0logs\serverstart.log" 2>&1

REM 待办事项: 验证成功安装的检查措施

REM 创建默认的server.properties和eula.txt
IF NOT EXIST "%~dp0server.properties" (
	ECHO 找不到server.properties，正在创建... 1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO INFO: 找不到server.properties......使用默认值 1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO view-distance=8 1>> "%~dp0server.properties"  2> "%~dp0logs\serverstart.log"
	ECHO allow-flight=true 1>> "%~dp0server.properties"  2> "%~dp0logs\serverstart.log"
	ECHO level-type=BIOMESOP 1>> "%~dp0server.properties"  2> "%~dp0logs\serverstart.log"
	ECHO snooper-enabled=false 1>> "%~dp0server.properties"  2> "%~dp0logs\serverstart.log"
	ECHO max-tick-time=90000 1>> "%~dp0server.properties"  2> "%~dp0logs\serverstart.log"
	ECHO motd=%MC_SERVER_PACKNAME% 1>> "%~dp0server.properties"  2> "%~dp0logs\serverstart.log"
	)
IF NOT EXIST "%~dp0eula.txt" (
	ECHO 找不到eula.txt，正在创建... 1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO INFO: 找不到eula.txt... 使用默认值 1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO eula=false 1>> "%~dp0eula.txt"  2> "%~dp0logs\serverstart.log"
	)

REM 清理文件
DEL /F /Q "%~dp0tmp-forgeinstaller.jar"  1>>  "%~dp0logs\serverstart.log" 2>&1
DEL /F /Q "%~dp0forge-%MC_SERVER_MCVER%.html"  1>>  "%~dp0logs\serverstart.log" 2>&1

:INSTALLCOMPLETE
COLOR 2F
ECHO.
ECHO.
ECHO.
ECHO ========================================================
ECHO  %MC_SERVER_PACKNAME% 的服务器文件现在已准备就绪！
ECHO ========================================================
ECHO INFO: 下载/安装完成... 1>>  "%~dp0logs\serverstart.log" 2>&1
>nul TIMEOUT 1
ECHO 下载/安装Forge和Mineworld二进制文件成功
ECHO.
>nul TIMEOUT 3
IF /i "%1"=="install" (
	ECHO "install"参数被传递给脚本，现在退出而不启动服务器...
	ECHO 你可以在没有"install"参数的情况下使用同样的脚本来运行服务器 
	ECHO 或者手动启动forge JAR，亦或者上传到你的面板/VPS
	ECHO WARN: "install"参数被传递给脚本，现在退出而不启动服务器 1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO.
	GOTO CLEANUP
) ELSE (
	GOTO BEGIN
)

:DOWNLOADSPONGE
REM 自动下载尚未实装，也可能永远不会实装
REM 在github上抓取bootsreapper的链接存在问题

REM ---Rename any spongeforge*.jar to .jar.disabled
REM (FOR /f "tokens=* delims=*" %%x in ('dir "%~dp0mods\*spongeforge*.jar" /B /O:-D') DO MOVE /Y "%%x" "%%x.disabled") 1>> "%~dp0logs\serverstart.log" 2>&1
REM ---Rename any sponge*bootstrap*.jar to .jar.disabled
REM (FOR /f "tokens=* delims=*" %%x in ('dir "%~dp0*sponge*bootstrap*.jar" /B /O:-D') DO MOVE /Y "%~dp0%%x" "%%x.disabled") 1>> "%~dp0logs\serverstart.log" 2>&1
REM ---Download spongeforge index to parse for jar download
REM bitsadmin /rawreturn /nowrap /transfer dlspongehtml /download /priority FOREGROUND "http://files.minecraftforge.net/maven/org/spongepowered/spongeforge/index_%MC_SERVER_MCVER%.html" "%~dp0spongeforge-%MC_SERVER_MCVER%.html"  1>> "%~dp0logs\serverstart.log" 2>&1
REM ---Download sponge bootstrap html to parse for jar download 
REM bitsadmin /rawreturn /nowrap /transfer dlspongebootstrap /download /priority FOREGROUND "https://api.github.com/repos/simon816/spongebootstrap/releases/latest" "%~dp0spongebootstrap.html"  1>> "%~dp0logs\serverstart.log" 2>&1
REM ---Find latest bootstrap download and save to var
REM FOR /f tokens^=* delims^=^" %%F in ('findstr /ir "https:\/\/github.*releases.*Bootstrap.*\.jar" "%~dp0spongebootstrap.html"') DO (
REM 	SET "MC_SERVER_SPONGEBOOTSTRAPURL=%%F"
REM 	FOR /f tokens^=^30 delims^=^/ %%B in ("%%G") DO ECHO Bootstrap Filename: %%B
REM ---Find latest SpongeForge download and save to var http://files.minecraftforge.net/maven/org/spongepowered/spongeforge/1.10.2-2281-5.2.0-BETA-2274/spongeforge-1.10.2-2281-5.2.0-BETA-2274.jar
REM FOR /f tokens^=* delims^=^" %%G in ('findstr /ir "https:\/\/files.*%MC_SERVER_MCVER%.*%MC_SERVER_FORGESHORT%.*[0-9]*\.jar" "%~dp0spongeforge-%MC_SERVER_MCVER%.html"') DO (
REM 	SET "MC_SERVER_SPONGEURL=%%G"
REM 	FOR /f tokens^=^30 delims^=^/ %%S in ("%%G") DO ECHO SpongeForge Filename: %%S
REM )
REM ECHO DEBUG: Attempting to download "%MC_SERVER_SPONGEBOOTSTRAPURL%" 1>> "%~dp0logs\serverstart.log" 2>&1
REM bitsadmin /rawreturn /nowrap /transfer dlforgeinstaller /download /priority FOREGROUND %MC_SERVER_SPONGEBOOTSTRAPURL% "%~dp0%%B"  1>>  "%~dp0logs\serverstart.log" 2>&1
REM ECHO DEBUG: Attempting to download "%MC_SERVER_SPONGEURL%" 1>> "%~dp0logs\serverstart.log" 2>&1
REM bitsadmin /rawreturn /nowrap /transfer dlforgeinstaller /download /priority FOREGROUND %MC_SERVER_SPONGEURL% "%~dp0%%S"  1>>  "%~dp0logs\serverstart.log" 2>&1

CLS
TITLE 错误！找不到 SPONGE 文件！！
COLOR cf
ECHO.
ECHO **** ERROR ****
ECHO 已在settings.cfg中启用 Sponge ，但没有找到必要的文件.....
ECHO.
ECHO 如果你要使用 Sponge 请注意以下内容:
ECHO    1) "MODS"文件夹中必须有一个与Forge相匹配的SpongeForge JAR. %MC_SERVER_FORGESHORT%
ECHO    2) SpongeBootstrap JAR必须与Forge位于同一文件夹中 "universal"
ECHO.
ECHO **** 注意 ****
ECHO 如果使用Sponge，将有可能不会得到modpack开发人员的支持。
ECHO 如使用，则风险自负，或在settings.cfg中禁用Sponge。
ECHO.
TIMEOUT 1 >nul 
COLOR 4f
TIMEOUT 1 >nul 
COLOR cf
TIMEOUT 1 >nul 
COLOR 4f
TIMEOUT 1 >nul
COLOR cf
TIMEOUT 1 >nul
COLOR 0c
PAUSE
GOTO CLEANUP

:ERROR
COLOR cf
TITLE ERROR - "%MC_SERVER_ERROR_REASON%" - 脚本停止
ECHO.
ECHO **** ERROR ****
ECHO 有一个错误，代码: "%MC_SERVER_ERROR_REASON%"
ECHO ERROR: 标记错误，原因是: "%MC_SERVER_ERROR_REASON%" 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO.
TIMEOUT 1 >nul 
COLOR 4f
TIMEOUT 1 >nul 
COLOR cf
TIMEOUT 1 >nul 
COLOR 4f
TIMEOUT 1 >nul
COLOR cf
TIMEOUT 1 >nul
COLOR 0c
GOTO CLEANUP

:RESTARTER
COLOR 6F
REM 在开始完整的逻辑重启之前，快速检查EULA
>nul %MC_SYS32%\FIND.EXE /I "eula=true" "%~dp0eula.txt" || (
	TITLE ERROR: 需要先修改 EULA.TXT，然后才能启动 %MC_SERVER_PACKNAME% 服务器
	CLS
	ECHO.
	ECHO 在eula.txt文件中找不到"eula=true"
	ECHO 请编辑并保存EULA文件，然后继续
	ECHO.
	PAUSE
	GOTO STARTSERVER
	)

ECHO ERROR: 在 %MC_SERVER_CRASH_YYYYMMDD%:%MC_SERVER_CRASH_HHMMSS% 时，服务器已经停止. 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO 在 %MC_SERVER_CRASH_YYYYMMDD%:%MC_SERVER_CRASH_HHMMSS% 时，服务器已经停止.
ECHO 服务器有 %MC_SERVER_CRASH_COUNTER% 次的连续停止/崩溃, 每次停止时间都在 %MC_SERVER_CRASH_TIMER% 秒以内...
ECHO DEBUG: 服务器有 %MC_SERVER_CRASH_COUNTER% 次的连续停止/崩溃, 每次停止时间都在 %MC_SERVER_CRASH_TIMER% 秒以内... 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO.

REM Arithmetic to check DAYS since last crash
REM Testing working in USA region. Hoping other regional formats don't mess it up
SET /a MC_SERVER_TMP_FLAG="%date:~10,4%%date:~4,2%%date:~7,2%-%MC_SERVER_CRASH_YYYYMMDD%"

REM If more than one calendar day, reset timer/counter.
REM Yes, this means over midnight it's not accurate.
REM Nobody's perfect.
IF %MC_SERVER_TMP_FLAG% GTR 0 (
	ECHO 距离上次崩溃/重启已超过一天......重置崩溃计数器/定时器
	ECHO INFO: 距离上次崩溃/重启已超过一天......重置崩溃计数器/定时器 1>>  "%~dp0logs\serverstart.log" 2>&1
	SET MC_SERVER_CRASH_YYYYMMDD=%date:~10,4%%date:~4,2%%date:~7,2%
	SET MC_SERVER_CRASH_HHMMSS=%time:~0,2%%time:~3,2%%time:~6,2%
	SET MC_SERVER_CRASH_COUNTER=0
	GOTO BEGIN
)

REM Arithmetic to check SECONDS since last crash
SET /a MC_SERVER_TMP_FLAG="%time:~0,2%%time:~3,2%%time:~6,2%-%MC_SERVER_CRASH_HHMMSS%"

REM If more than specified seconds (from config variable), reset timer/counter.	
IF %MC_SERVER_TMP_FLAG% GTR %MC_SERVER_CRASH_TIMER% (
	ECHO 最后一次崩溃/启动是在 %MC_SERVER_TMP_FLAG%+ 秒前。
	ECHO INFO: 最后一次崩溃/启动是在 %MC_SERVER_TMP_FLAG%+ 秒前 1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO 自上次崩溃/重启后超过%MC_SERVER_CRASH_TIMER%秒......重置崩溃计数器/定时器。
	ECHO INFO: 自上次崩溃/重启后超过%MC_SERVER_CRASH_TIMER%秒......重置崩溃计数器/定时器 1>>  "%~dp0logs\serverstart.log" 2>&1
	SET MC_SERVER_CRASH_YYYYMMDD=%date:~10,4%%date:~4,2%%date:~7,2%
	SET MC_SERVER_CRASH_HHMMSS=%time:~0,2%%time:~3,2%%time:~6,2%
	SET MC_SERVER_CRASH_COUNTER=0
	REM GOTO BEGIN
)

REM If we are still here, time difference is within threshold to increment counter
REM Check if already max failures:
IF %MC_SERVER_CRASH_COUNTER% GEQ %MC_SERVER_MAX_CRASH% (
	COLOR cf
	SET MC_SERVER_ERROR_REASON=TooManyCrashes:%MC_SERVER_CRASH_COUNTER%
	ECHO INFO: 最后一次崩溃/启动是在 %MC_SERVER_TMP_FLAG%+ 秒前 1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO.
	ECHO.
	ECHO ===================================================
	ECHO  ERROR: 服务器已经停止/崩溃太多次了!
	ECHO ===================================================
	ECHO ERROR: 服务器停止/崩溃次数过多! 1>>  "%~dp0logs\serverstart.log" 2>&1
	ECHO.
	>nul TIMEOUT 1
	ECHO %MC_SERVER_CRASH_COUNTER% 在 %MC_SERVER_CRASH_TIMER% 秒内，已经对每一次的崩溃进行了统计。
	>nul TIMEOUT 1
	GOTO ERROR
	)

REM Still under threshold so lets increment and restart
ECHO INFO: 最后一次崩溃/启动是在 %MC_SERVER_TMP_FLAG%+ 秒前。 1>>  "%~dp0logs\serverstart.log" 2>&1
SET /a "MC_SERVER_CRASH_COUNTER=%MC_SERVER_CRASH_COUNTER%+1"
SET MC_SERVER_CRASH_YYYYMMDD=%date:~10,4%%date:~4,2%%date:~7,2%
SET MC_SERVER_CRASH_HHMMSS=%time:~0,2%%time:~3,2%%time:~6,2%

ECHO DEBUG: Total consecutive crash/stops within time threshold: %MC_SERVER_CRASH_COUNTER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO.
ECHO.
ECHO.
ECHO.
ECHO 服务器将在不到 30 秒内 “自动” 重新启动...
CHOICE /M:"现在重启 (Y) 停止重启并退出 (N)" /T:30 /D:Y
IF %ERRORLEVEL% GEQ 2 (
	ECHO INFO: 服务器在自动重启之前被手动停止 1>>  "%~dp0logs\serverstart.log" 2>&1
	GOTO CLEANUP
) ELSE ( 
	GOTO BEGIN
)

:CLEANUP
ECHO WARN: 服务器启动脚本正在退出。转储当前配置选项: 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_MAX_RAM=%MC_SERVER_MAX_RAM% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGE_JAR=%MC_SERVER_FORGE_JAR% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_SPONGE_BOOT=%MC_SERVER_SPONGE_BOOT% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_JVM_ARGS=%MC_SERVER_JVM_ARGS% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_MAX_CRASH=%MC_SERVER_MAX_CRASH% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_CRASH_TIMER=%MC_SERVER_CRASH_TIMER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_IGNORE_OFFLINE=%MC_SERVER_IGNORE_OFFLINE% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_RUN_FROM_BAD_FOLDER=%MC_SERVER_RUN_FROM_BAD_FOLDER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_MCVER=%MC_SERVER_MCVER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGEVER=%MC_SERVER_FORGEVER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGESHORT=%MC_SERVER_FORGESHORT% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_FORGEURL=%MC_SERVER_FORGEURL% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_HIGH_PRIORITY=%MC_SERVER_HIGH_PRIORITY% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_SPONGE=%MC_SERVER_SPONGE% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_PACKNAME=%MC_SERVER_PACKNAME% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_SPONGEURL=%MC_SERVER_SPONGEURL% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_SPONGEBOOTSTRAPURL=%MC_SERVER_SPONGEBOOTSTRAPURL% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_ERROR_REASON=%MC_SERVER_ERROR_REASON% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_TMP_FLAG=%MC_SERVER_TMP_FLAG% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_CRASH_COUNTER=%MC_SERVER_CRASH_COUNTER% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_CRASH_YYYYMMDD=%MC_SERVER_CRASH_YYYYMMDD% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: MC_SERVER_CRASH_HHMMSS=%MC_SERVER_CRASH_HHMMSS% 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: Current directory file listing: 1>>  "%~dp0logs\serverstart.log" 2>&1
DIR 1>>  "%~dp0logs\serverstart.log" 2>&1
ECHO DEBUG: JAVA version output (java -d64 -version): 1>>  "%~dp0logs\serverstart.log" 2>&1
java -d64 -version 1>>  "%~dp0logs\serverstart.log" 2>&1

REM Clear variables -- probably not necessary since we SETLOCAL but doesn't hurt either
SET MC_SERVER_MAX_RAM=
SET MC_SERVER_FORGE_JAR=
SET MC_SERVER_SPONGE_BOOT=
SET MC_SERVER_JVM_ARGS=
SET MC_SERVER_MAX_CRASH=
SET MC_SERVER_CRASH_TIMER=
SET MC_SERVER_IGNORE_OFFLINE=
SET MC_SERVER_RUN_FROM_BAD_FOLDER=
SET MC_SERVER_MCVER=
SET MC_SERVER_FORGEVER=
SET MC_SERVER_FORGESHORT=
SET MC_SERVER_FORGEURL=
SET MC_SERVER_SPONGE=
SET MC_SERVER_HIGH_PRIORITY=
SET MC_SERVER_PACKNAME=
SET MC_SERVER_SPONGEURL=
SET MC_SERVER_SPONGEBOOTSTRAPURL=
SET MC_SERVER_ERROR_REASON=
SET MC_SERVER_TMP_FLAG=
SET MC_SERVER_CRASH_COUNTER=
SET MC_SERVER_CRASH_YYYYMMDD=
SET MC_SERVER_CRASH_HHMMSS=

REM Reset bitsadmin in case things got hung or errored
%MC_SYS32%\bitsadmin.exe /reset 1>>  "%~dp0logs\serverstart.log" 2>&1

COLOR

:EOF
