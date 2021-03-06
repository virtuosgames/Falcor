@echo off
setlocal ENABLEDELAYEDEXPANSION 

set "action="
if "%1"=="clean" set action=clean
if "%1"=="build" set action=build
if "%1"=="rebuild" set action=rebuild
if not defined action goto usage

set "config="
if "%3"=="released3d12" set config=released3d12
if "%3"=="debugd3d12" set config=debugd3d12
if "%3"=="releasevk" set config=releasevk
if "%3"=="debugvk" set config=debugvk
if not defined config ( 
    echo Unknown configuration : %3.  Available configs: released3d12, debugd3d12, releasevk, debugvk
    exit /B 1
)

goto findVS

:findVS
set VS_WHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
if not EXIST "%VS_WHERE%" goto cantFindVs
for /f "usebackq tokens=*" %%i in (`"%VS_WHERE%" -latest -property installationPath`) do (
  set VS_INSTALL_DIR=%%i
)

:act
set solution=%2
set project=%4
set errFileSuffix=_BuildLog.txt
set CL=%CL% /D_TEST_
if defined project (
    set errFile="%project%%errFileSuffix%"
    echo %action%ing the %config% config of project %project% in solution %2
    call "%VS_INSTALL_DIR%\Common7\IDE\devenv.com" %solution% /%action% %config% /project %project% > !errFile!
    call type !errFile!
) else (
    set errFile="Solution%errFileSuffix%"
    echo %action%ing %config% config of solution %2
    call "%VS_INSTALL_DIR%\Common7\IDE\devenv.com" %solution% /%action% %config% > !errFile! 2>&1
)
if not %errorlevel%==0 (
    goto buildFailed 
)else (
    del !errFile!
)

exit /B 0

:buildFailed
echo Build Failed
call type !errFile!
exit /B 1

:cantFindVs
echo Build Failed. Failed to find Visual Studio. 
echo Set environment var VSWHERE to the location of vswhere.exe 
echo Or Set VS_INSTALL_DIR to the location of your visual studio 2017 install 
exit /B 1

:usage
echo Usage: BuildSolution.bat ^<clean^|build^|rebuild^> solution config [projectName(entire sln if omitted)]
exit /B 1
