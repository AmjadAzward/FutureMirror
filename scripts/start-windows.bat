@echo off
setlocal
cd /d "%~dp0.."
echo ==========================================
echo     FutureMirror - Windows Desktop
 echo ==========================================
where flutter >nul 2>nul
if errorlevel 1 (
 echo Flutter not found. Install Flutter SDK, Visual Studio C++ Desktop workload,
 echo and enable Windows desktop support. See README.md.
 pause
 exit /b 1
)
if not exist windows (
 echo Generating Windows Flutter host project...
 call flutter create --platforms=windows --project-name future_mirror .
 if errorlevel 1 goto fail
)
where cargo >nul 2>nul
if not errorlevel 1 (
 echo Compiling Rust engine...
 pushd engine
 cargo build --release
 if errorlevel 1 echo WARNING: Rust build failed. Dart fallback will still work.
 popd
) else echo Rust not installed: using fully offline Dart simulation fallback.
echo Installing Flutter dependencies...
call flutter pub get
if errorlevel 1 goto fail
echo Starting FutureMirror...
call flutter run -d windows
if errorlevel 1 goto fail
exit /b 0
:fail
echo An error occurred. Review the output above and README.md.
pause
exit /b 1
