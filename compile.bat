@echo off

setlocal
set curr=%CD%

cd ../sourcemod-compiler
set compdir=%CD%
cd %curr%
"%compdir%/spcomp.exe" TestMod.sp -oTestMod.smx

cd %curr%
endlocal
