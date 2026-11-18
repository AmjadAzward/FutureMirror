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
echo Release compiled in build\windows\x64\runner\Release\
echo IMPORTANT: Copy engine\target\release\futuremirror_engine.exe under
 echo release\engine\target\release\ and launch app from release root.
pause
