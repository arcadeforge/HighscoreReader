@echo off

set PATH=%PATH%;lib\;lib\windows-amd64\;lib\windows-x86\

rem Checking if the "reg" command is available
reg /? >NUL 2>NUL
if %ERRORLEVEL% EQU 1 goto DEFAULTCMD

set key=HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment
reg query "%key%" >nul 2>nul
if %ERRORLEVEL% EQU 0 goto KEYFOUND
set key=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment
reg query "%key%" >nul 2>nul
if %ERRORLEVEL% EQU 0 goto KEYFOUND
set key=HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit
reg query "%key%" >nul 2>nul
if %ERRORLEVEL% EQU 0 goto KEYFOUND
set key=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit
reg query "%key%" >nul 2>nul
if %ERRORLEVEL% EQU 0 goto KEYFOUND

goto DEFAULTCMD

:KEYFOUND
set JAVA_VERSION=
set JAVA_HOME=
for /f "tokens=3* skip=2" %%a in ('reg query "%key%" /v CurrentVersion') do set JAVA_VERSION=%%a
for /f "tokens=2* skip=2" %%a in ('reg query "%key%\%JAVA_VERSION%" /v JavaHome') do set JAVA_HOME=%%b

set JAVA_CMD=%JAVA_HOME%\bin\java.exe
if not exist "%JAVA_CMD%" goto JAVAMISSING

for /f "delims=. tokens=1-2" %%v in ("%JAVA_VERSION%") do (set MINOR=%%w)
if %MINOR% GEQ 7 goto RUN

goto JAVAMISSING

:DEFAULTCMD
set JAVA_CMD=java.exe
"%JAVA_CMD%" -version >nul 2>nul
if %ERRORLEVEL% EQU 1 goto JAVAMISSING

for /f tokens^=2-5^ delims^=.-_^" %%j in ('java -fullversion 2^>^&1') do (set MINOR=%%k)
if [%MINOR%] == [] goto JAVAMISSING
if %MINOR% GEQ 7 goto RUN

goto JAVAMISSING

:RUN
rem echo %JAVA_CMD%
"%JAVA_CMD%" -jar %~dp0\hi2txt.jar %*
goto END

:JAVAMISSING
@echo The required version of Java (1.7+) has not been installed
@echo Go to
@echo     http://www.oracle.com/technetwork/java/javase/downloads/index.html
@echo to install the Java JRE.
pause

:END
