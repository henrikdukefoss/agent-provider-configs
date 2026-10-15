# Adds an OpenAI-compatible profile: writes [providers.myprovider] to ~/.jcode/config.toml
# and stores the key in jcode's private config dir (e.g. ~/.config/jcode/provider-myprovider.env).
printf '%s' "$YOUR_PROVIDER_API_KEY" | jcode provider add myprovider \
  --base-url https://YOUR_PROVIDER/v1 \
  --model MODEL_ID \
  --api-key-stdin \
  --set-default

# One request to check the profile:
jcode --provider-profile myprovider auth-test --no-tool-smoke

# Alternatives:
#   --api-key-env YOUR_PROVIDER_API_KEY   read the key from an env var instead of storing it
#   --no-api-key                          for a localhost server
#   --context-window 128000               when jcode doesn't know the model
#   --model-catalog                       list the models from the provider's /models
