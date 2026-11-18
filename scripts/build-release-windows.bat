@echo off
setlocal
cd /d "%~dp0.."
where flutter >nul 2>nul || (echo Flutter SDK is required. & pause & exit /b 1)
if not exist windows call flutter create --platforms=windows --project-name future_mirror .
where cargo >nul 2>nul
if not errorlevel 1 (
 pushd engine
 cargo build --release
 popd
)
call flutter pub get
call flutter build windows --release
if errorlevel 1 (pause & exit /b 1)
if exist package\FutureMirror rmdir /s /q package\FutureMirror
mkdir package\FutureMirror
xcopy /e /i /y build\windows\x64\runner\Release\* package\FutureMirror\ >nul
if exist engine\target\release\futuremirror_engine.exe (
 mkdir package\FutureMirror\engine\target\release
 copy /y engine\target\release\futuremirror_engine.exe package\FutureMirror\engine\target\release\ >nul
)
copy /y README.md package\FutureMirror\ >nul
copy /y LICENSE package\FutureMirror\ >nul
powershell -NoProfile -Command "Compress-Archive -Path 'package\FutureMirror' -DestinationPath 'package\FutureMirror-Windows-x64.zip' -Force"
if errorlevel 1 (pause & exit /b 1)
echo Portable release created at package\FutureMirror-Windows-x64.zip
pause
