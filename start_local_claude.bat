@echo off
cd /d "%~dp0"

echo ========================================================
echo               CLEANING UP OLD PROCESSES
echo ========================================================
taskkill /F /IM litellm.exe >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq LiteLLM*" >nul 2>&1

echo.
echo ========================================================
echo               CHECKING CLAUDE AUTH CONFIG
echo ========================================================
:: 只在配置不存在时创建假的认证配置 （需要修改为实际路径）
if not exist "C:\Users\admin\.claude.json" (
    echo .claude.json not found, creating fake auth config...
    (
    echo {
    echo   "apiKey": "sk-1234",
    echo   "baseUrl": "http://127.0.0.1:4000",
    echo   "authenticated": true
    echo }
    ) > "C:\Users\admin\.claude.json"
    echo Fake auth config created.
) else (
    echo .claude.json already exists, skipping creation.
)

echo.
echo ========================================================
echo               STARTING LITELLM PROXY
echo ========================================================
:: 使用当前目录下的配置文件
start "LiteLLM Debug Window" cmd /k "litellm --config litellm_config.yaml --port 4000 --debug --drop_params"
timeout /t 5 /nobreak >nul

echo.
echo ========================================================
echo               FORCE SETTING ENVIRONMENT VARS
echo ========================================================
:: 强制设置环境变量
set ANTHROPIC_BASE_URL=http://127.0.0.1:4000
set ANTHROPIC_AUTH_TOKEN=sk-1234
set ANTHROPIC_API_KEY=

echo ANTHROPIC_BASE_URL forced to: %ANTHROPIC_BASE_URL%

echo.
echo ========================================================
echo               STARTING CLAUDE BINARY
echo ========================================================
echo Model: claude-opus-4-5-20251101 (Mapped to Local)
echo.

:: 请修改为你自己的 Claude 可执行文件路径
"claude.exe" --model claude-opus-4-5-20251101

pause
