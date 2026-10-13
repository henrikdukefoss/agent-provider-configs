# Source this file, or paste into your shell, before running `claude`.
# No /v1 on the base URL: Claude Code appends /v1/messages itself.
export ANTHROPIC_BASE_URL="https://YOUR_PROVIDER"
export ANTHROPIC_AUTH_TOKEN="$YOUR_PROVIDER_API_KEY"   # sent as Authorization: Bearer
export ANTHROPIC_MODEL="MODEL_ID"
