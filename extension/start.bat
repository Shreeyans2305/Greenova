@echo off
REM Quick start script for GreenMart E-commerce + GreenNova Extension (Windows)

echo.
echo 🌿 GreenMart + GreenNova Extension Setup
echo ===========================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if errorlevel 1 (
    echo ❌ Node.js not found. Please install Node.js (v14+) from https://nodejs.org
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
for /f "tokens=*" %%i in ('npm -v') do set NPM_VERSION=%%i

echo ✅ Node.js %NODE_VERSION%
echo ✅ npm %NPM_VERSION%
echo.

REM Check if npm packages are installed
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    call npm install
    echo.
) else (
    echo ✅ Dependencies already installed
    echo.
)

echo 🚀 Starting servers...
echo.
echo About to start React development server on http://localhost:3000
echo.
echo Next steps:
echo 1. Keep this terminal running
echo 2. Open Chrome and load the extension:
echo    - Go to chrome://extensions/
echo    - Enable 'Developer Mode'
echo    - Click 'Load unpacked'
echo    - Select: c:\Users\nttga\Desktop\Greenova\extension
echo 3. Make sure Ollama is running on http://127.0.0.1:11434
echo 4. Navigate to http://localhost:3000
echo.
echo Press Ctrl+C to stop
echo.

call npm start
pause
