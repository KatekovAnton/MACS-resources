@echo off

set masterfolder=%cd%

mkdir ToolsForNewGraphics\build
cd ToolsForNewGraphics\build
rem call cmake -G "Visual Studio 16 2019" -T host=x86 -A Win32 ..
call cmake -G "Visual Studio 17 2022" -T host=x86 -A Win32 -D WIN32CONSOLE=TRUE ..

cd %masterfolder%
