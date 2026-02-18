@echo off
title Alerta Builder
color 0A

echo ===================================================
echo   ALERTA AUTOMATED BUILDER
echo ===================================================
echo.
echo 1. Cleaning project cache...
call flutter clean

echo.
echo 2. Downloading dependencies (This might take time)...
call flutter pub get

echo.
echo 3. Compiling APK...
call flutter build apk

echo.
echo ===================================================
echo   BUILD PROCESS COMPLETED
echo ===================================================
echo.
echo If successful, your APK is in: build\app\outputs\flutter-apk\
echo.
pause
