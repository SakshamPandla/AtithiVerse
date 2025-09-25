@echo off
echo 🚀 Starting AtithiVerse Services...
echo ==================================================

echo 🤖 Starting AI Service on port 5001...
start "AI Service" cmd /k "python travel_bot.py"

timeout /t 3 /nobreak >nul

echo 🌐 Starting Main Website on port 5000...
start "Main Website" cmd /k "python Website/app.py"

echo ✅ Both services are starting...
echo.
echo 📍 AI Service: http://127.0.0.1:5001
echo 📍 Main Website: http://127.0.0.1:5000
echo.
echo Press any key to close this window...
pause >nul
