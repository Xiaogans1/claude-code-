# claude-code-
使用claude code 直连本地模型 绕过官方api验证登录 可以在完全离线情况下 使用本地算力服务器模型

模型映射: 当 Claude Code 请求 claude-opus-4-5-20251101 时,LiteLLM 实际调用你的本地模型

用户输入
  ↓
Claude Code (以为在用官方 API)
  ↓
发送请求到 http://127.0.0.1:4000 (环境变量设置的)
  ↓
LiteLLM 代理接收请求
  ↓
查找配置: claude-opus-4-5-20251101 → openai/qwen2.5:latest
  ↓
转换为 OpenAI 格式请求
  ↓
发送到 Ollama (http://localhost:11434)
  ↓
Ollama 执行推理
  ↓
返回结果给 LiteLLM
  ↓
LiteLLM 转换为 Claude API 格式
  ↓
返回给 Claude Code
  ↓
显示给用户

使用说明:

1. 安装 Claude Code
npm install -g @anthropic-ai/claude-code

2. 安装 LiteLLM
pip install 'litellm[proxy]' -i https://pypi.tuna.tsinghua.edu.cn/simple
