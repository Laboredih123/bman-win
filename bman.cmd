@echo off
setlocal enabledelayedexpansion

set OPTION=%1%
set MAJOR=%2%
set MINOR=%3%

set BMAN_DOWNLOAD=C:\Users\Twigo\Documents\bman

if not exist %BMAN_DOWNLOAD% mkdir %BMAN_DOWNLOAD%
if not exist %BMAN_DOWNLOAD%\bin mkdir %BMAN_DOWNLOAD%\bin
if not exist %BMAN_DOWNLOAD%\bin\bman.cmd copy %~dp0 %BMAN_DOWNLOAD%\bin\

if "%OPTION%"=="-h" goto :help
if "%OPTION%"=="--help" goto :help
if "%OPTION%"=="-g" goto :get
if "%OPTION%"=="--get" goto :get
if "%OPTION%"=="-r" goto :remove
if "%OPTION%"=="--remove" goto :remove
if "%OPTION%"=="-s" goto :set
if "%OPTION%"=="--set" goto :set
if "%OPTION%"=="-l" goto :list
if "%OPTION%"=="--list" goto :list

echo Invalid option. Use 'bman -h' for more into.
goto :eof

:help
	echo bman command line options:
	echo 	-h --help			Displays this message
	echo 	-g --get [MAJOR] [MINOR]	Downloads and configures the specified version of Byond
	echo 	-r --remove [MAJOR] [MINOR]	Deletes the specified version of Byond
	echo 	-s --set [MAJOR] [MINOR]	Sets the version of Byond which is used
	echo 	-l --list			Lists the installed versions of Byond

	goto :eof

:get
	pushd %BMAN_DOWNLOAD%

	if exist %MAJOR%-%MINOR% echo Version %MAJOR%-%MINOR% is already downloaded, delete it before trying to download it again. & popd & goto :eof
	powershell -command "& { iwr http://www.byond.com/download/build/%MAJOR%/%MAJOR%.%MINOR%_byond.zip -OutFile byond.zip }"
	if not exist byond.zip echo Could not download Byond version %MAJOR%-%MINOR%. & popd & goto :eof
	powershell -command "& { Expand-Archive -Force %BMAN_DOWNLOAD%\byond.zip %BMAN_DOWNLOAD% }"
	rename byond %MAJOR%-%MINOR%
	del byond.zip

	echo @start %BMAN_DOWNLOAD%\%MAJOR%-%MINOR%\bin\byond.exe %%* > %MAJOR%-%MINOR%\byond.cmd
	echo @start %BMAN_DOWNLOAD%\%MAJOR%-%MINOR%\bin\dm.exe %%* > %MAJOR%-%MINOR%\dm.cmd
	echo @start %BMAN_DOWNLOAD%\%MAJOR%-%MINOR%\bin\dreammaker.exe %%* > %MAJOR%-%MINOR%\dreammaker.cmd
	echo @start %BMAN_DOWNLOAD%\%MAJOR%-%MINOR%\bin\dreamdaemon.exe %%* > %MAJOR%-%MINOR%\dreamdaemon.cmd
	echo @start %BMAN_DOWNLOAD%\%MAJOR%\%MINOR%\bin\dreamseeker.exe %%* > %MAJOR%-%MINOR%\dreamseeker.cmd

	popd
	goto :eof

:remove
	pushd %BMAN_DOWNLOAD%

	rmdir /s /q %MAJOR%-%MINOR%

	popd
	goto :eof

:set
	pushd %BMAN_DOWNLOAD%

	if not exist %MAJOR%-%MINOR% echo You do not have Byond version %MAJOR%-%MINOR% downloaded. & popd & goto :eof
	if not exist bin mkdir bin & copy %~dp0 bin

	copy /y %MAJOR%-%MINOR%\byond.cmd bin\byond.cmd
	copy /y %MAJOR%-%MINOR%\dm.cmd bin\dm.cmd
	copy /y %MAJOR%-%MINOR%\dreammaker.cmd bin\dreammaker.cmd
	copy /y %MAJOR%-%MINOR%\dreamdaemon.cmd bin\dreamdaemon.cmd
	copy /y %MAJOR%-%MINOR%\dreamseeker.cmd bin\dreamseeker.cmd

	popd
	goto :eof

:list
	pushd %BMAN_DOWNLOAD%
	echo Installed Byond versions:

	for /D %%d in (*-*) do echo 	%%d

	popd
	goto :eof
