@echo off

set OPTION=%1%
set MAJOR=%2%
set MINOR=%3%

set BMAN_DOWNLOAD=C:\ByondVersions

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
	if %MAJOR% LSS 425 echo Major version too old, zip files not available. & popd & goto :eof
	powershell -command "& { iwr http://www.byond.com/download/build/%MAJOR%/%MAJOR%.%MINOR%_byond.zip -OutFile byond.zip }"
	if not exist byond.zip echo Could not download Byond version %MAJOR%-%MINOR%. & popd & goto :eof
	powershell -command "& { Expand-Archive -Force %BMAN_DOWNLOAD%\byond.zip %BMAN_DOWNLOAD% }"
	rename byond %MAJOR%-%MINOR%
	del byond.zip

	pushd %MAJOR%-%MINOR%\bin

	for %%i in (*) do mklink /h ..\%%i %%i

	popd
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

	echo Killing processes
	taskkill /F /IM byond.exe
	taskkill /F /IM dreamseeker.exe
	taskkill /F /IM dreammaker.exe
	taskkill /F /IM dreamdaemon.exe
	
	echo Copying Files
	for %%a in (%MAJOR%-%MINOR%\*.*) do copy /y /l %%a bin\ >nul && echo %%a copied
	popd
	echo Starting Byond
	start byond.exe
	goto :eof

:list
	pushd %BMAN_DOWNLOAD%
	echo Installed Byond versions:

	for /d %%d in (*-*) do echo 	%%d

	popd
	goto :eof
