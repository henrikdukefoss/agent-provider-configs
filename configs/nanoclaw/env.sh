# Set before running setup (bash nanoclaw.sh). Anthropic Messages only.
# No /v1: the Claude Agent SDK appends /v1/messages itself.
export NANOCLAW_ANTHROPIC_BASE_URL="https://YOUR_PROVIDER"
export NANOCLAW_ANTHROPIC_AUTH_TOKEN="$YOUR_PROVIDER_API_KEY"   # goes to the credential vault, sent as Authorization: Bearer
bash nanoclaw.sh

# Model: per agent group, or install-wide in the host .env
# ncl groups config update --id <group-id> --model MODEL_ID && ncl groups restart --id <group-id>
# echo 'NANOCLAW_DEFAULT_MODEL=MODEL_ID' >> .env
