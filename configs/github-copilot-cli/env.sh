# Source this file, or paste into your shell, before running `copilot`.
# OpenAI-compatible (Chat Completions) is the default provider type.
export COPILOT_PROVIDER_BASE_URL="https://YOUR_PROVIDER/v1"
export COPILOT_PROVIDER_API_KEY="$YOUR_PROVIDER_API_KEY"
export COPILOT_MODEL="MODEL_ID"

# Optional, when Copilot does not know the model name:
# export COPILOT_PROVIDER_MAX_PROMPT_TOKENS=128000
# export COPILOT_PROVIDER_MAX_OUTPUT_TOKENS=16000

# Anthropic-compatible instead:
# export COPILOT_PROVIDER_TYPE=anthropic
# export COPILOT_PROVIDER_BASE_URL="https://YOUR_PROVIDER"
