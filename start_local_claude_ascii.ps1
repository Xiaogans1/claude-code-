# start_local_claude.ps1

# --- Configuration ---
# 支持多种本地模型服务，请根据你使用的服务填写配置

# 1. Ollama 示例:
#    $ModelName = "qwen2.5:latest"  # 或 "llama3.1", "mistral" 等
#    $VllmBaseUrl = "http://localhost:11434"  # Ollama 默认端口
#    $VllmApiKey = "ollama"  # Ollama 不需要真实 API key，填任意值即可

# 2. vLLM 示例:
#    $ModelName = "Qwen3-Next-80B-A3B-Instruct"
#    $VllmBaseUrl = "http://10.0.0.182:8000/v1"
#    $VllmApiKey = "your-api-key"

# 3. LM Studio 示例:
#    $ModelName = "your-model-name"
#    $VllmBaseUrl = "http://localhost:1234/v1"  # LM Studio 默认端口
#    $VllmApiKey = "lm-studio"

# 4. LocalAI 示例:
#    $ModelName = "your-model-name"
#    $VllmBaseUrl = "http://localhost:8080/v1"
#    $VllmApiKey = "local-ai"

# 请在下方填写你的实际配置:
$ModelName = ""
$VllmBaseUrl = ""
$VllmApiKey = ""

# Configuration file path
$ConfigDir = $PSScriptRoot
$ConfigPath = Join-Path $ConfigDir "litellm_config.yaml"

# --- 1. Kill existing LiteLLM processes ---
Write-Host "Cleaning up old processes..." -ForegroundColor Yellow
Get-Process -Name "litellm" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*litellm*" } | Stop-Process -Force

# --- 2. Generate Config ---
$ConfigContent = @"
model_list:
  - model_name: claude-opus-4-5-20251101
    litellm_params:
      model: openai/$ModelName
      api_key: $VllmApiKey
      api_base: $VllmBaseUrl

  - model_name: claude-3-5-sonnet-20241022
    litellm_params:
      model: openai/$ModelName
      api_key: $VllmApiKey
      api_base: $VllmBaseUrl

general_settings:
  master_key: sk-1234
"@

Set-Content -Path $ConfigPath -Value $ConfigContent -Encoding UTF8
Write-Host "Config updated." -ForegroundColor Green

# --- 3. Start LiteLLM (Visible Window) ---
Write-Host "Starting LiteLLM proxy..." -ForegroundColor Cyan
Start-Process -FilePath "powershell" -ArgumentList "-NoExit", "-Command", "litellm --config `"$ConfigPath`" --port 4000 --debug"
Start-Sleep -Seconds 5

# --- 4. Display Banner ---
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "         >>> USING LOCAL MODEL (NOT OFFICIAL API) <<<          " -ForegroundColor Green
Write-Host "         Proxy:  http://127.0.0.1:4000                         " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

# --- 5. Start Claude with IN-LINE Environment Variables ---
# This is the key fix: We set env vars specifically for this command execution
Write-Host "Starting Claude Code..." -ForegroundColor Cyan

# Use cmd /c to force environment variable setting for the immediate command
cmd /c "set ANTHROPIC_BASE_URL=http://127.0.0.1:4000&& set ANTHROPIC_AUTH_TOKEN=sk-1234&& set ANTHROPIC_API_KEY=&& claude --model claude-opus-4-5-20251101"