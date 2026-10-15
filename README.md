# agent-provider-configs

Copy-paste configs for pointing AI coding agents at any OpenAI-compatible or Anthropic-compatible API:
a gateway, a router, another model vendor, or a server on your own machine.

31 agents plus the Magpie provider manager, 21 provider presets, a source link for every key. Last checked: **2026-10-15**.

## How do I point an AI coding agent at a custom OpenAI-compatible API?

You need three values: a **base URL**, an **API key**, and a **model ID** that the provider serves.
Where they go depends on the agent:

- **Claude Code** reads env vars: `ANTHROPIC_BASE_URL` (no `/v1`), `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_MODEL`. It only speaks the Anthropic Messages API. Its aliases and background calls request their own Claude model IDs, so also set every `ANTHROPIC_DEFAULT_*_MODEL`; [claude-code-provider](https://github.com/henrikdukefoss/claude-code-provider) does this and checks the result with one request.
- **OpenCode** and **Kilo Code** take a `provider` block in `opencode.json` / `kilo.json` with `"npm": "@ai-sdk/openai-compatible"` and `options.baseURL`.
- **Codex CLI** takes a `[model_providers.<id>]` table in `~/.codex/config.toml`. It only speaks the OpenAI **Responses** API now; `wire_api = "chat"` was removed.
- **Cline, Roo Code, Cursor, Copilot, JetBrains** have an "OpenAI Compatible" option in their settings UI.
- Most other agents take a JSON or YAML provider entry. Find yours in the table, copy the block, replace the three placeholders.

Placeholders used everywhere: `https://YOUR_PROVIDER/v1`, `YOUR_PROVIDER_API_KEY`, `MODEL_ID`. Real values for 21 providers are in [Provider presets](#provider-presets).

### The four mistakes behind most "404" and "model not found" errors

1. **`/v1` or no `/v1`.** OpenAI-style base URLs end in `/v1` (the client appends `/chat/completions`). Claude Code, Zed's `anthropic_compatible`, Goose, Roo Code and Factory's `anthropic` type want the Anthropic base URL **without** `/v1` because they append `/v1/messages` themselves. OpenCode, Kilo, Continue and Crush use AI SDK or similar clients that want it **with** `/v1`. Each section below says which.
2. **Wrong protocol.** Codex CLI needs `/v1/responses`. Claude Code needs `/v1/messages`. An endpoint that only serves `/v1/chat/completions` works with neither.
3. **Model ID.** Use the exact ID from the provider's `GET /v1/models`, including any prefix (`anthropic/...`, `accounts/fireworks/models/...`). Aider additionally needs an `openai/` prefix in front of it.
4. **A key from somewhere else wins.** A saved login, a stale `OPENAI_BASE_URL`, or a settings-file `env` block can override what you exported. The gotchas per agent list the known cases.

[`check.sh`](#checksh-test-a-provider-first) tests a base URL, key and model ID in one command before you touch an agent.

## Contents

| Agent | Config location | Chat Completions | Responses | Anthropic Messages | Checked |
| --- | --- | :---: | :---: | :---: | --- |
| [Claude Code](#claude-code) | env vars or `~/.claude/settings.json` | | | yes | CLI run |
| [OpenCode](#opencode) | `opencode.json` | yes | yes | yes | CLI run |
| [Codex CLI](#codex-cli) | `~/.codex/config.toml` | removed | yes | | CLI run |
| [Cline](#cline) | extension settings, `cline auth` | yes | | yes (extension) | docs, source |
| [Kilo Code](#kilo-code) | `~/.config/kilo/kilo.json` | yes | yes | yes | docs, source |
| [Roo Code](#roo-code) | extension settings, import JSON | yes | | yes | docs, source |
| [Continue](#continue) | `~/.continue/config.yaml` | yes | yes | yes | docs, source |
| [Aider](#aider) | env vars, `.aider.conf.yml` | yes | | via LiteLLM | docs, source |
| [Hermes Agent](#hermes-agent) | `~/.hermes/config.yaml` | yes | yes | yes | docs, source |
| [OpenClaw](#openclaw) | `~/.openclaw/openclaw.json` | yes | yes | yes | docs, source |
| [Pi](#pi) | `~/.pi/agent/models.json` | yes | yes | yes | docs, source |
| [oh-my-pi](#oh-my-pi) | `~/.omp/agent/models.yml` | yes | yes | yes | docs, source |
| [Crush](#crush) | `crushrc` (or legacy `crush.json`) | yes | yes | yes | docs, source |
| [Goose](#goose) | `~/.config/goose/custom_providers/*.json` | yes | yes | yes | docs, source |
| [Qwen Code](#qwen-code) | `~/.qwen/settings.json` | yes | yes | yes | docs |
| [Factory Droid](#factory-droid) | `~/.factory/settings.json` | yes | yes | yes | docs |
| [Amp](#amp) | Settings → Model Routing → Custom URL | yes | yes | yes | docs |
| [Grok Build](#grok-build) | `~/.grok/config.toml` | yes | yes | yes | docs, source |
| [DeepSeek Harness](#deepseek-harness) | Settings → Models, `cordis.patch.yml` | yes | yes | yes | docs |
| [Command Code](#command-code) | `/connect`, `~/.commandcode/providers.json` | yes | yes | yes | docs |
| [jcode](#jcode) | `jcode provider add` → `~/.jcode/config.toml` | yes | | | docs, source |
| [Docker Agent](#docker-agent) | agent YAML, `~/.config/cagent/config.yaml` | yes | yes | yes | docs, source |
| [Zed](#zed) | `settings.json` | yes | yes | yes | docs, source |
| [Cursor (BYOK)](#cursor-byok) | Settings → Models | yes | | | docs, staff posts |
| [GitHub Copilot in VS Code](#github-copilot-in-vs-code-custom-endpoint) | `chatLanguageModels.json` | yes | yes | yes | docs |
| [GitHub Copilot CLI](#github-copilot-cli) | `COPILOT_PROVIDER_*` env vars | yes | | yes | docs |
| [JetBrains AI Assistant and Junie CLI](#jetbrains-ai-assistant-and-junie-cli) | IDE settings, `~/.junie/models/*.json` | yes | yes (Junie) | yes (Junie) | docs |
| [NanoClaw](#nanoclaw) | `NANOCLAW_ANTHROPIC_*` env vars at setup | | | yes | docs |
| [Octop](#octop) | Model Management → Custom Providers | yes | | yes | docs, source |
| [Rakazo](#rakazo) | `.env` flag + Settings → Models | yes | | | docs, source |
| [nanoMuse](#nanomuse) | Connections, or `[llm]` in `config.toml` | yes | yes | | docs |
| [Magpie](#magpie) (provider manager) | Providers → Add provider, import link | yes | yes | yes | docs |
| [Gemini CLI](#gemini-cli) | not supported | | | | docs, source |

Also: [Provider presets](#provider-presets) · [check.sh](#checksh-test-a-provider-first) · [How this was checked](#how-this-was-checked) · [Contributing](#contributing)

Every config shown is also a plain file in [`configs/`](configs/).

## Provider presets

Base URLs as each provider's own docs state them. "Anthropic base URL" is the value for `ANTHROPIC_BASE_URL` (Claude Code), so it has no `/v1`. Listed alphabetically within each group; no ranking is implied.

**Gateways and routers** (one key, many vendors' models)

| Provider | OpenAI-compatible base URL | Anthropic base URL | Responses API | Model ID format | How you pay | Source |
| --- | --- | --- | :---: | --- | --- | --- |
| Cloudflare AI Gateway | `https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/compat` | pass-through to Anthropic only | | `provider/model` | core features free; 5% fee on Unified Billing credits | [docs](https://developers.cloudflare.com/ai-gateway/usage/chat-completion/) |
| LiteLLM proxy (self-hosted) | `http://localhost:4000` | `http://localhost:4000` | yes | names from your proxy config | self-hosted, you bring upstream keys | [docs](https://docs.litellm.ai/docs/tutorials/claude_responses_api) |
| OpenRouter | `https://openrouter.ai/api/v1` | `https://openrouter.ai/api` | yes | `vendor/model` | pay per token; fee on credit purchases | [docs](https://openrouter.ai/docs/quickstart), [Claude Code](https://openrouter.ai/docs/cookbook/coding-agents/claude-code-integration) |
| Portkey | `https://api.portkey.ai/v1` | `https://api.portkey.ai` | yes | `@provider-slug/model` | see Portkey pricing | [docs](https://portkey.ai/docs/api-reference/inference-api/introduction), [Claude Code](https://portkey.ai/docs/integrations/libraries/claude-code) |
| Requesty | `https://router.requesty.ai/v1` | `https://router.requesty.ai` | yes | `provider/model` | pay per token; fee on credit top-ups | [docs](https://docs.requesty.ai/quickstart), [Claude Code](https://docs.requesty.ai/integrations/claude-code) |
| Standard Compute | `https://api.stdcmpt.com/v1` | `https://api.stdcmpt.com` | yes | `vendor/model`, or `standardcompute` to let it pick | flat monthly plan from $19, stops at budget | [docs](https://docs.standardcompute.com/) |
| Vercel AI Gateway | `https://ai-gateway.vercel.sh/v1` | `https://ai-gateway.vercel.sh` | yes | `provider/model` | pay per token at provider list price | [docs](https://vercel.com/docs/ai-gateway/sdks-and-apis/openai-chat-completions), [Anthropic API](https://vercel.com/docs/ai-gateway/sdks-and-apis/anthropic-messages-api) |

[![Add to Magpie](https://usemagpie.ai/img/add-to-magpie.svg)](https://usemagpie.ai/import#name=Standard+Compute&id=standardcompute&chat=https%3A%2F%2Fapi.stdcmpt.com%2Fv1&anthropic=https%3A%2F%2Fapi.stdcmpt.com&website=https%3A%2F%2Fstandardcompute.com&keys=https%3A%2F%2Fstandardcompute.com%2Fdashboard%2Fapi-keys&icon=https%3A%2F%2Fstandardcompute.com%2Fapple-icon.png)

Using Magpie? One click adds Standard Compute as a provider (you paste your key in Magpie). Guide: https://standardcompute.com/integrations/magpie

**Model vendors** (their own models)

| Provider | OpenAI-compatible base URL | Anthropic base URL | Responses API | Model ID format | Source |
| --- | --- | --- | :---: | --- | --- |
| Alibaba Model Studio (Singapore) | `https://{WorkspaceId}.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1` | `https://{WorkspaceId}.ap-southeast-1.maas.aliyuncs.com/apps/anthropic` | yes | bare (`qwen-plus`) | [docs](https://www.alibabacloud.com/help/en/model-studio/compatibility-of-openai-with-dashscope), [Claude Code](https://www.alibabacloud.com/help/en/model-studio/claude-code) |
| Cerebras | `https://api.cerebras.ai/v1` | | | bare | [docs](https://inference-docs.cerebras.ai/resources/openai) |
| DeepSeek | `https://api.deepseek.com` | `https://api.deepseek.com/anthropic` | | bare | [docs](https://api-docs.deepseek.com/), [Anthropic API](https://api-docs.deepseek.com/guides/anthropic_api) |
| Fireworks AI | `https://api.fireworks.ai/inference/v1` | `https://api.fireworks.ai/inference` | yes | `accounts/fireworks/models/<model>` | [docs](https://docs.fireworks.ai/tools-sdks/openai-compatibility), [Anthropic API](https://docs.fireworks.ai/tools-sdks/anthropic-compatibility) |
| Groq | `https://api.groq.com/openai/v1` | | yes | bare | [docs](https://console.groq.com/docs/openai) |
| MiniMax | `https://api.minimax.io/v1` | `https://api.minimax.io/anthropic` | yes | bare | [docs](https://platform.minimax.io/docs/api-reference/text-openai-api), [Claude Code](https://platform.minimax.io/docs/m-plan/claude-code) |
| Mistral | `https://api.mistral.ai/v1` | | | bare | [docs](https://docs.mistral.ai/api) |
| Moonshot AI (Kimi) | `https://api.moonshot.ai/v1` | `https://api.moonshot.ai/anthropic` | yes | bare | [docs](https://platform.kimi.ai/docs/guide/agent-support), [Claude Code](https://platform.kimi.ai/docs/guide/claude-code-kimi) |
| Together AI | `https://api.together.ai/v1` | | | `org/model` | [docs](https://docs.together.ai/docs/openai-api-compatibility) |
| Z.ai (GLM) | `https://api.z.ai/api/paas/v4` (Coding Plan: `https://api.z.ai/api/coding/paas/v4`) | `https://api.z.ai/api/anthropic` | | bare | [docs](https://docs.z.ai/guides/develop/http/introduction), [Claude Code](https://docs.z.ai/scenario-example/develop-tools/claude) |

**Local servers and first-party APIs**

| Provider | OpenAI-compatible base URL | Anthropic base URL | Responses API | Model ID format | Source |
| --- | --- | --- | :---: | --- | --- |
| Anthropic | | `https://api.anthropic.com` | | bare | [docs](https://platform.claude.com/docs/en/api/overview) |
| LM Studio | `http://localhost:1234/v1` | `http://localhost:1234` | yes | local model identifier | [docs](https://lmstudio.ai/docs/app/api/endpoints/openai), [Claude Code](https://lmstudio.ai/docs/integrations/claude-code) |
| Ollama | `http://localhost:11434/v1` | `http://localhost:11434` | yes | `name:tag` | [docs](https://docs.ollama.com/api/openai-compatibility), [Anthropic API](https://docs.ollama.com/api/anthropic-compatibility) |
| OpenAI | `https://api.openai.com/v1` | | yes | bare | [docs](https://developers.openai.com/api/reference/overview) |

Blank cells mean the provider's docs don't document that API; it may still exist. Notes:

- **Z.ai paths end in `/v4`**, not `/v1`. Use them as given.
- **Alibaba's** older `https://dashscope-intl.aliyuncs.com/compatible-mode/v1` still appears in guides; Alibaba asks users to move to the workspace URL. Keys only work in the region where they were created.
- **Cloudflare** authenticates with a `cf-aig-authorization: Bearer <token>` header. Its Anthropic URL forwards to Anthropic only.
- **LiteLLM** has two Anthropic routes: the unified `http://localhost:4000` (every model in your config) and `/anthropic` (pass-through to Anthropic only).
- **Portkey** with Claude Code also needs `ANTHROPIC_CUSTOM_HEADERS` carrying `x-portkey-api-key` and `x-portkey-provider`.
- **Ollama and LM Studio** need a key value even though they ignore it (`ollama`, `lmstudio`).
- Local servers only work with agents that call the API from your machine. **Cursor** calls it from Cursor's servers, so it needs a public HTTPS URL.

Something wrong or missing? [Open a PR](CONTRIBUTING.md) with a link to the provider's docs.

---

## Claude Code

**Where:** env vars, or the `env` block of `~/.claude/settings.json`. **API:** Anthropic Messages only (`POST /v1/messages`).

Quickest, for one shell:

```sh
# Source this file, or paste into your shell, before running `claude`.
# No /v1 on the base URL: Claude Code appends /v1/messages itself.
export ANTHROPIC_BASE_URL="https://YOUR_PROVIDER"
export ANTHROPIC_AUTH_TOKEN="$YOUR_PROVIDER_API_KEY"   # sent as Authorization: Bearer
export ANTHROPIC_MODEL="MODEL_ID"
```

Permanent, in `~/.claude/settings.json`, without writing the key into the file:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_BASE_URL": "https://YOUR_PROVIDER",
    "ANTHROPIC_MODEL": "MODEL_ID",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "MODEL_ID",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "MODEL_ID",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "SMALL_MODEL_ID"
  },
  "apiKeyHelper": "printf %s \"$YOUR_PROVIDER_API_KEY\""
}
```

**Env vars**

| Variable | What it does |
| --- | --- |
| `ANTHROPIC_BASE_URL` | Provider's Anthropic base URL, **without `/v1`** |
| `ANTHROPIC_AUTH_TOKEN` | Key, sent as `Authorization: Bearer` |
| `ANTHROPIC_API_KEY` | Key, sent as `x-api-key` |
| `ANTHROPIC_MODEL` | Main model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL` | What the `opus` / `sonnet` / `haiku` aliases resolve to. The Haiku one also runs background tasks. `ANTHROPIC_SMALL_FAST_MODEL` is deprecated in favour of it. |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `CLAUDE_CODE_MAX_CONTEXT_TOKENS` | Context window for model IDs Claude Code doesn't recognise (it assumes 200K) |
| `ANTHROPIC_CUSTOM_HEADERS` | Extra headers, `Name: value` per line |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` turns off telemetry and other non-API traffic |

**Gotchas**
- **No `/v1`.** Claude Code appends `/v1/messages`. With `ANTHROPIC_BASE_URL=https://host/v1` it calls `https://host/v1/v1/messages`, which is a 404 on real providers. (Seen in our test run below.)
- **A saved claude.ai login stays active** if you only set `ANTHROPIC_BASE_URL`. Set `ANTHROPIC_AUTH_TOKEN` (takes over immediately) or `ANTHROPIC_API_KEY` (interactive mode asks you to approve it once). `/status` shows which base URL and credential are in use.
- **Both key variables set means both headers are sent** (`Authorization` and `x-api-key`), and `apiKeyHelper` always sends both. OpenRouter and Vercel tell you to set `ANTHROPIC_API_KEY=""` and use `ANTHROPIC_AUTH_TOKEN`; follow your provider's page.
- **A settings-file `env` value beats a shell export** of the same name. If an export seems ignored, check `~/.claude/settings.json` and `.claude/settings.local.json`.
- **Unrecognised model IDs** get a 200K context assumption and Claude Code still sends newer request features. If the provider returns 400s, try `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.
- MCP tool search is off for non-Anthropic hosts; `ENABLE_TOOL_SEARCH=true` turns it back on.
- The VS Code extension reads its own `claudeCode.environmentVariables` setting, not your shell.
- Anthropic's docs say it doesn't support routing Claude Code to non-Claude models through a gateway. Many providers do it anyway; expect differences in tool use and thinking.

**Sources:** [LLM gateway: connect](https://code.claude.com/docs/en/llm-gateway-connect) · [Gateway protocol](https://code.claude.com/docs/en/llm-gateway-protocol) · [Env vars](https://code.claude.com/docs/en/env-vars) · [Authentication precedence](https://code.claude.com/docs/en/authentication) · [Settings](https://code.claude.com/docs/en/settings)

## OpenCode

**Where:** `opencode.json` in the project root, or `~/.config/opencode/opencode.json`. **API:** set by the `npm` package: `@ai-sdk/openai-compatible` (Chat Completions), `@ai-sdk/openai` (Responses), `@ai-sdk/anthropic` (Anthropic Messages).

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "myprovider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "My Provider",
      "options": {
        "baseURL": "https://YOUR_PROVIDER/v1",
        "apiKey": "{env:YOUR_PROVIDER_API_KEY}"
      },
      "models": {
        "MODEL_ID": {
          "name": "My model",
          "limit": { "context": 128000, "output": 16384 }
        }
      }
    }
  },
  "model": "myprovider/MODEL_ID"
}
```

Anthropic-compatible endpoint ([`configs/opencode/opencode.anthropic.json`](configs/opencode/opencode.anthropic.json)): same shape with `"npm": "@ai-sdk/anthropic"` and `"baseURL": "https://YOUR_PROVIDER/v1"`. **Keep the `/v1` here**, unlike Claude Code.

**Env vars:** `{env:NAME}` substitutes any env var in the config (unset becomes an empty string). `{file:path}` reads a file. `OPENCODE_CONFIG` points at a different config file. You can also store the key with `/connect` → **Other**, using the same provider ID.

**Gotchas**
- Select models as `providerID/modelID`. The keys under `models` must be the IDs the endpoint serves.
- Set `limit.context` and `limit.output`. Without them OpenCode can't tell how full the context is; it only knows limits for models in its built-in catalog.
- Responses-only endpoints need `@ai-sdk/openai`, not `-compatible`.
- OpenCode 2 is available as an opt-in upgrade with a new config shape (`providers`, `package`, `settings`). Its migration guide says v1 configs like this one keep working, so this repo shows the v1 shape.
- `opencode debug config` prints the resolved config with keys redacted; `opencode models myprovider` lists what it sees.

**Sources:** [Providers docs](https://opencode.ai/docs/providers/) · [Config docs](https://opencode.ai/docs/config/) · [docs source](https://github.com/anomalyco/opencode/blob/dev/packages/web/src/content/docs/providers.mdx)

## Codex CLI

**Where:** `~/.codex/config.toml` (or `$CODEX_HOME/config.toml`). **API:** OpenAI Responses only.

```toml
# ~/.codex/config.toml
model = "MODEL_ID"
model_provider = "myprovider"

[model_providers.myprovider]
name = "My Provider"
base_url = "https://YOUR_PROVIDER/v1"   # Codex calls {base_url}/responses
env_key = "YOUR_PROVIDER_API_KEY"       # name of the env var, not the key itself
wire_api = "responses"                  # "chat" was removed; the provider must support /v1/responses
```

**Env vars:** the one named by `env_key`, sent as `Authorization: Bearer`. `env_http_headers` maps more headers to env vars.

**Gotchas**
- **`wire_api = "chat"` is gone.** Codex now refuses to start: "`wire_api = "chat"` is no longer supported". The provider must serve `POST {base_url}/responses`. If yours only has Chat Completions, put a gateway that translates (LiteLLM, for one) in between.
- **Provider tables only work in the user config.** A project `.codex/config.toml` ignores `model_provider` and `model_providers` and prints a warning.
- **Profiles moved** (Codex 0.134.0 and later): `--profile work` reads `~/.codex/work.config.toml`; `[profiles.work]` inside `config.toml` is no longer read.
- `openai`, `ollama` and `lmstudio` are reserved provider IDs. To proxy the built-in OpenAI provider, set top-level `openai_base_url` instead.
- Unknown model IDs print "Model metadata ... not found" and use defaults. Set `model_context_window` if the default is wrong.
- `codex --strict-config` rejects unknown keys; `codex doctor` checks the install and config.

**Sources:** [Advanced config: custom model providers](https://developers.openai.com/codex/config-advanced) · [Config reference](https://learn.chatgpt.com/docs/config-file/config-reference) · [`model-provider-info/src/lib.rs`](https://github.com/openai/codex/blob/main/codex-rs/model-provider-info/src/lib.rs) · [Discussion #7782 (chat removal)](https://github.com/openai/codex/discussions/7782)

## Cline

**Where:** VS Code extension settings, or the `cline` CLI. **API:** Chat Completions (provider "OpenAI Compatible"); Anthropic Messages through the Anthropic provider with a custom base URL (extension only).

VS Code: open Cline settings, set **API Provider** to **OpenAI Compatible**, then fill in **Base URL** (`https://YOUR_PROVIDER/v1`), **OpenAI Compatible API Key** and **Model ID**. Under **Model Configuration**, set **Context Window Size**, **Max Output Tokens** and **Supports Images** to match the model.

CLI:

```sh
cline auth -p openai-compatible -k "$YOUR_PROVIDER_API_KEY" -m MODEL_ID -b https://YOUR_PROVIDER/v1
cline "your task"
```

**Env vars:** the `openai-compatible` provider falls back to `OPENAI_API_KEY`, the `anthropic` provider to `ANTHROPIC_API_KEY`. There is no base-URL env var. `CLINE_DIR` moves the CLI's config directory (default `~/.cline`).

**Gotchas**
- The base URL includes `/v1`.
- The CLI's `-b` flag only works for OpenAI and OpenAI-compatible providers. For an Anthropic-compatible endpoint, use the extension: Anthropic provider, tick **Use custom base URL**.
- Unset prices in Model Configuration make paid requests show as $0 in Cline's cost display. That is display only.
- Prefer `cline auth` over editing `~/.cline/data/settings/providers.json` by hand; the file layout is internal.

**Sources:** [OpenAI Compatible provider docs](https://github.com/cline/cline/blob/main/docs/provider-config/openai-compatible.mdx) · [CLI reference](https://github.com/cline/cline/blob/main/docs/cli/cli-reference.mdx) · [`auth.ts`](https://github.com/cline/cline/blob/main/apps/cli/src/commands/auth.ts) · [Anthropic provider docs](https://github.com/cline/cline/blob/main/docs/provider-config/anthropic.mdx)

## Kilo Code

**Where:** VS Code extension (**Settings → Providers → Custom provider**) or a `kilo.json` file shared with the Kilo CLI. Kilo's config is OpenCode-based. **API:** Chat Completions, Responses or Anthropic Messages, chosen by the `npm` package.

`~/.config/kilo/kilo.json`:

```json
{
  "$schema": "https://app.kilo.ai/config.json",
  "model": "myprovider/MODEL_ID",
  "provider": {
    "myprovider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "My Provider",
      "options": {
        "baseURL": "https://YOUR_PROVIDER/v1",
        "apiKey": "{env:YOUR_PROVIDER_API_KEY}"
      },
      "models": {
        "MODEL_ID": {
          "name": "My model",
          "tool_call": true,
          "limit": { "context": 128000, "output": 16384 }
        }
      }
    }
  }
}
```

| `npm` package | Protocol | `baseURL` |
| --- | --- | --- |
| `@ai-sdk/openai-compatible` | Chat Completions | `https://YOUR_PROVIDER/v1` |
| `@ai-sdk/openai` | Responses | `https://YOUR_PROVIDER/v1` |
| `@ai-sdk/anthropic` | Anthropic Messages | `https://YOUR_PROVIDER/v1` (with `/v1`) |

**Env vars:** whatever you name in `{env:VAR}`. `KILO_CONFIG` (file path), `KILO_CONFIG_DIR` and `KILO_CONFIG_CONTENT` override where config comes from.

**Gotchas**
- `{env:VAR}` only resolves in trusted config: the global `~/.config/kilo/` file, `KILO_CONFIG`/`KILO_CONFIG_CONTENT`, or managed config. In a `kilo.json` committed to a repo it is ignored with a warning and auth fails. Keep the provider block global.
- Without `limit.context` and `limit.output`, context management is limited and output falls back to 32,000 tokens.
- Set `tool_call: true` for agent use. Unknown models default to text-only; add `"modalities": {"input": ["text", "image"], "output": ["text"]}` and `"attachment": true` for images.
- The `@ai-sdk/anthropic` base URL needs `/v1`, unlike Claude Code.

**Sources:** [Kilo docs: OpenAI-compatible](https://github.com/Kilo-Org/kilocode/blob/main/packages/kilo-docs/pages/ai-providers/openai-compatible.md) · [Custom models](https://github.com/Kilo-Org/kilocode/blob/main/packages/kilo-docs/pages/code-with-ai/agents/custom-models.md) · [`config.ts`](https://github.com/Kilo-Org/kilocode/blob/main/packages/opencode/src/config/config.ts)

## Roo Code

> The Roo Code repository was archived in May 2026 (last release 3.54.0). The extension still installs and works, but expect no fixes when providers change.

**Where:** extension settings, or an import file. **API:** Chat Completions (provider "OpenAI Compatible"); Anthropic Messages through the Anthropic provider with a custom base URL.

UI: gear icon, **API Provider** = **OpenAI Compatible**, then **Base URL**, **API Key**, **Model**. Set **Context Window Size**, **Max Output Tokens** and **Image Support** in the custom model section.

To configure it from a file, point the VS Code setting `"roo-cline.autoImportSettingsPath": "~/roo-code-settings.json"` at a file like this (import merges profiles, it never deletes):

```json
{
  "providerProfiles": {
    "currentApiConfigName": "my-provider",
    "apiConfigs": {
      "my-provider": {
        "apiProvider": "openai",
        "openAiBaseUrl": "https://YOUR_PROVIDER/v1",
        "openAiApiKey": "YOUR_PROVIDER_API_KEY",
        "openAiModelId": "MODEL_ID",
        "openAiCustomModelInfo": {
          "contextWindow": 128000,
          "maxTokens": 16384,
          "supportsImages": false,
          "supportsPromptCache": false
        }
      }
    }
  }
}
```

Anthropic-compatible profile: `"apiProvider": "anthropic"`, `"anthropicBaseUrl": "https://YOUR_PROVIDER"` (no `/v1`), `"apiKey"`, `"apiModelId"`. Add `"anthropicUseAuthToken": true` if the provider wants `Authorization: Bearer` instead of `x-api-key`.

**Env vars:** none. Keys live in VS Code secret storage; the import file holds the key in plain text, so keep it out of git.

**Gotchas**
- Internally, "OpenAI Compatible" is `apiProvider: "openai"`; the official OpenAI provider is `"openai-native"`.
- Roo uses native tool calling only. A model without OpenAI-style tool calls can't run tasks.
- `contextWindow` and `supportsPromptCache` are required in `openAiCustomModelInfo`.

**Sources:** [OpenAI-compatible docs](https://github.com/RooCodeInc/Roo-Code-Docs/blob/main/docs/providers/openai-compatible.md) · [Settings import/export](https://github.com/RooCodeInc/Roo-Code-Docs/blob/main/docs/features/settings-management.md) · [`provider-settings.ts`](https://github.com/RooCodeInc/Roo-Code/blob/main/packages/types/src/provider-settings.ts) · [`model.ts`](https://github.com/RooCodeInc/Roo-Code/blob/main/packages/types/src/model.ts)

## Continue

**Where:** `~/.continue/config.yaml` (Windows `%USERPROFILE%\.continue\config.yaml`), read by the IDE extensions and the `cn` CLI. **API:** Chat Completions (`provider: openai`), Responses (automatic for some model names, see gotchas), Anthropic Messages (`provider: anthropic`).

```yaml
name: My Config
version: 0.0.1
schema: v1
models:
  - name: My Provider Model
    provider: openai
    model: MODEL_ID
    apiBase: https://YOUR_PROVIDER/v1
    apiKey: ${{ secrets.YOUR_PROVIDER_API_KEY }}
    roles: [chat, edit, apply]
    capabilities: [tool_use]
    defaultCompletionOptions:
      contextLength: 128000
      maxTokens: 8192
```

Anthropic-compatible: `provider: anthropic` and `apiBase: https://YOUR_PROVIDER/v1` (Continue resolves `messages` relative to `apiBase`, so include `/v1`).

**Env vars:** `${{ secrets.NAME }}` is looked up in `<workspace>/.env`, then `<workspace>/.continue/.env`, then `~/.continue/.env`, then the process environment. The IDE extensions can't see your shell's env vars, so put the key in `~/.continue/.env`. The `cn` CLI does read process env.

**Gotchas**
- **Responses auto-switch.** With `provider: openai`, model names matching `o1`/`o3`-style or `gpt-5`+ are sent to `/responses`, even on a custom `apiBase`. If your provider has no Responses endpoint, set `useResponsesApi: false` on the model.
- Continue guesses capabilities from the model name. For a custom model ID, set `capabilities: [tool_use]` or agent mode gets no tools; add `image_input` for images.
- `config.json` is deprecated; use `config.yaml`.

**Sources:** [OpenAI provider docs](https://github.com/continuedev/continue/blob/main/docs/customize/model-providers/top-level/openai.mdx) · [Anthropic provider docs](https://github.com/continuedev/continue/blob/main/docs/customize/model-providers/top-level/anthropic.mdx) · [config.yaml reference](https://github.com/continuedev/continue/blob/main/docs/reference.mdx) · [`core/llm/index.ts`](https://github.com/continuedev/continue/blob/main/core/llm/index.ts)

## Aider

**Where:** env vars, or `.aider.conf.yml` in your home dir, git root or working dir. **API:** Chat Completions (`openai/` prefix). Anthropic-compatible endpoints work through LiteLLM's env vars, though Aider's docs don't cover it.

```sh
export OPENAI_API_BASE=https://YOUR_PROVIDER/v1
export OPENAI_API_KEY=$YOUR_PROVIDER_API_KEY
aider --model openai/MODEL_ID
```

Or in a file:

```yaml
# .aider.conf.yml (home dir, git root or cwd). Key: export OPENAI_API_KEY=... in your shell.
model: openai/MODEL_ID
openai-api-base: https://YOUR_PROVIDER/v1
```

For an Anthropic-compatible endpoint: `ANTHROPIC_API_BASE=https://YOUR_PROVIDER` (LiteLLM appends `/v1/messages`), `ANTHROPIC_API_KEY`, and `--model anthropic/MODEL_ID`.

**Env vars:** `OPENAI_API_BASE`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`. Every option also has an `AIDER_*` form (`AIDER_MODEL`, `AIDER_OPENAI_API_BASE`).

**Gotchas**
- **The `openai/` prefix is required** in front of the provider's model ID, even when that ID already has a slash (`openai/anthropic/claude-...`).
- **A stray `OPENAI_BASE_URL` wins.** Aider's `--openai-api-base` sets `OPENAI_API_BASE`, but LiteLLM checks `OPENAI_BASE_URL` first. Unset it if requests go to the wrong host.
- Unknown models print "Unknown context window size and costs". It's harmless; to fix it, add [`.aider.model.metadata.json`](configs/aider/.aider.model.metadata.json). The key must use the same `openai/` prefix.
- Unknown models default to the `whole` edit format. For capable models, set `edit_format: diff` in `.aider.model.settings.yml`.
- `aider --list-models <text>` shows what Aider knows about a model name.

**Sources:** [OpenAI-compatible APIs](https://aider.chat/docs/llms/openai-compat.html) · [API keys](https://aider.chat/docs/config/api-keys.html) · [Advanced model settings](https://aider.chat/docs/config/adv-model-settings.html) · [Sample `.aider.conf.yml`](https://github.com/Aider-AI/aider/blob/main/aider/website/assets/sample.aider.conf.yml)

## Hermes Agent

**Where:** `~/.hermes/config.yaml` (secrets in `~/.hermes/.env`; `HERMES_HOME` moves both). **API:** `chat_completions`, `codex_responses` (Responses) or `anthropic_messages`, set per provider with `transport`.

```yaml
# ~/.hermes/config.yaml
providers:
  myprovider:
    api: https://YOUR_PROVIDER/v1
    key_env: YOUR_PROVIDER_API_KEY
    transport: chat_completions
    default_model: MODEL_ID
    models:
      MODEL_ID: { context_length: 128000 }
model:
  provider: custom:myprovider
  default: MODEL_ID
```

For an Anthropic-compatible endpoint, add a second entry with `api: https://YOUR_PROVIDER/anthropic` (or whatever your provider documents) and `transport: anthropic_messages`. The interactive route is `hermes model` → **Custom endpoint**.

**Env vars:** the one named in `key_env`, or `api_key: "${NAME}"`. Only the `${NAME}` form is expanded; a bare `$NAME` is not.

**Gotchas**
- `OPENAI_BASE_URL` is no longer read for custom endpoints, and `LLM_MODEL` was removed. Older guides use both.
- If `key_env` names an empty variable, Hermes sends the placeholder `no-key-required` and you get a 401.
- Base URLs ending in `/anthropic` are detected as Anthropic Messages automatically; others default to Chat Completions.
- The old top-level `custom_providers:` list still loads; `hermes update` migrates it to `providers:`.
- Without a detected context length Hermes assumes 128K. Set `context_length` per model.
- `hermes doctor` reports config problems.

**Sources:** [Providers docs](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/integrations/providers.md) · [Configuration](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/configuration.md) · [`cli-config.yaml.example`](https://github.com/NousResearch/hermes-agent/blob/main/cli-config.yaml.example)

## OpenClaw

**Where:** `~/.openclaw/openclaw.json` (JSON5; `OPENCLAW_CONFIG_PATH` overrides). **API:** set by `api`: `openai-completions`, `openai-responses` or `anthropic-messages`.

```json
{
  "agents": { "defaults": { "model": { "primary": "myprovider/MODEL_ID" } } },
  "models": {
    "mode": "merge",
    "providers": {
      "myprovider": {
        "baseUrl": "https://YOUR_PROVIDER/v1",
        "apiKey": "${YOUR_PROVIDER_API_KEY}",
        "api": "openai-completions",
        "models": [
          {
            "id": "MODEL_ID",
            "name": "My model",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 128000,
            "maxTokens": 16384
          }
        ]
      }
    }
  }
}
```

For an Anthropic-compatible endpoint: `"api": "anthropic-messages"` and the provider's Anthropic base URL. Non-interactive setup: `openclaw onboard --auth-choice custom-api-key --custom-base-url https://YOUR_PROVIDER/v1 --custom-model-id MODEL_ID --custom-compatibility openai`.

**Env vars:** `"${NAME}"` in `apiKey` (uppercase names only), or a SecretRef: `{ "source": "env", "provider": "default", "id": "NAME" }`. `.env` in the working dir and `~/.openclaw/.env` are loaded but never override variables already set.

**Gotchas**
- **Write `"${NAME}"`, not a bare `"NAME"`.** A bare uppercase string is sent as the literal key, except for a few names OpenClaw knows.
- A custom model needs an entry in `models.providers.<id>.models`. `agents.defaults.models` only holds aliases and parameters.
- **Unknown keys stop the Gateway from starting.** Run `openclaw config validate` or `openclaw doctor --fix` after editing.
- Remote OpenAI-compatible endpoints default to `supportsUsageInStreaming: false`, so token counts are missing until you set it to `true` under `compat`.
- `"mode": "merge"` keeps built-in providers; `"replace"` uses only what you configure.
- Mark vision models with `"input": ["text", "image"]`.

**Sources:** [Custom providers](https://github.com/openclaw/openclaw/blob/main/docs/gateway/config-tools/custom-providers.md) · [Configuration](https://github.com/openclaw/openclaw/blob/main/docs/gateway/configuration.md) · [`models` CLI](https://github.com/openclaw/openclaw/blob/main/docs/cli/models.md)

## Pi

The [pi.dev](https://pi.dev) coding agent. The repo moved to `earendil-works/pi` and the npm package is now `@earendil-works/pi-coding-agent` (`@mariozechner/pi-coding-agent` is deprecated).

**Where:** `~/.pi/agent/models.json` (`PI_CODING_AGENT_DIR` moves it); default model in `~/.pi/agent/settings.json` (`defaultProvider`, `defaultModel`). **API:** `openai-completions`, `openai-responses` or `anthropic-messages`.

```json
{
  "$schema": "https://pi.dev/schemas/models.schema.json",
  "providers": {
    "myprovider": {
      "baseUrl": "https://YOUR_PROVIDER/v1",
      "api": "openai-completions",
      "apiKey": "$YOUR_PROVIDER_API_KEY",
      "models": [
        {
          "id": "MODEL_ID",
          "name": "My model",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 128000,
          "maxTokens": 16384
        }
      ]
    }
  }
}
```

For an Anthropic-compatible endpoint: `"api": "anthropic-messages"` and `"baseUrl": "https://YOUR_PROVIDER"` (no `/v1`; the Anthropic SDK appends `/v1/messages`).

**Env vars:** only the one `apiKey` references.

**Gotchas**
- **`apiKey` changed meaning.** `"$NAME"` or `"${NAME}"` reads an env var; a plain string, even an ALL-CAPS one, is now sent as the literal key; `"!command"` runs a command. Guides that put a bare env var name in `apiKey` are out of date.
- A model doesn't show in `/model` until its key resolves.
- Defaults if omitted: `contextWindow` 128000, `maxTokens` 16384, text input only.
- `pi --list-models` prints load errors from `models.json` to stderr.

**Sources:** [Models docs](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/models.md) · [JSON schema](https://pi.dev/schemas/models.schema.json) · [`resolve-config-value.ts`](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/src/core/resolve-config-value.ts)

## oh-my-pi

The coding-first fork of Pi (`omp`).

**Where:** `~/.omp/agent/models.yml` (YAML, not Pi's JSON; a legacy `models.json` is migrated automatically). The default model goes in `~/.omp/agent/config.yml` under `modelRoles`. **API:** `openai-completions`, `openai-responses` or `anthropic-messages`.

```yaml
# ~/.omp/agent/models.yml
providers:
  myprovider:
    baseUrl: https://YOUR_PROVIDER/v1
    apiKey: YOUR_PROVIDER_API_KEY   # env var NAME; see the gotcha about unset variables
    api: openai-completions
    models:
      - id: MODEL_ID
        name: My model
        reasoning: false
        input: [text]
        contextWindow: 128000
        maxTokens: 16384
```

For an Anthropic-compatible endpoint: `api: anthropic-messages`, the provider's Anthropic base URL, and **`auth: apiKey`** (without it, omp sends OAuth-style requests). Add `authHeader: true` for `Authorization: Bearer`.

**Gotchas**
- **`apiKey` is the opposite of Pi's:** omp first reads it as an env var name. If that variable is unset, it sends the string itself, so an unset `YOUR_PROVIDER_API_KEY` goes out as `Bearer YOUR_PROVIDER_API_KEY` and you get a 401.
- **A broken `models.yml` doesn't stop omp.** It falls back to built-in models and shows a notification that's easy to miss. Check with `omp models`.
- Use `provider/modelId` when the same model ID exists under several providers.
- If a proxy rejects the tools' `strict` field, set `disableStrictTools: true` on the provider.

**Sources:** [Models docs](https://github.com/can1357/oh-my-pi/blob/main/docs/models.md) · [Config usage](https://github.com/can1357/oh-my-pi/blob/main/docs/config-usage.md)

## Crush

**Where:** `crushrc` (Bash with Crush built-ins) in `./.crushrc`, `./crushrc` or `~/.config/crush/crushrc`. `crush.json` still works but is deprecated. **API:** `--type openai-compat` (Chat Completions), `openai` (Responses), `anthropic` (Messages).

```sh
# ~/.config/crush/crushrc  (Bash with Crush built-ins)
provider add myprovider --name "My Provider" --type openai-compat \
  --base-url "https://YOUR_PROVIDER/v1" \
  --api-key "${YOUR_PROVIDER_API_KEY:?set YOUR_PROVIDER_API_KEY}"
model add myprovider/MODEL_ID --name "MODEL_ID" \
  --context-window 128000 --default-max-tokens 8192
model large myprovider/MODEL_ID
```

The same in legacy [`crush.json`](configs/crush/crush.json): a `providers.myprovider` object with `type`, `base_url`, `api_key: "$YOUR_PROVIDER_API_KEY"` and a `models` array (the schema requires all ten model fields).

For an Anthropic-compatible endpoint: `--type anthropic --base-url "https://YOUR_PROVIDER/v1"`. The key goes out as `x-api-key`; a value that starts with `Bearer ` is sent as `Authorization` instead.

**Gotchas**
- Use `openai-compat` for anything that isn't OpenAI itself. `openai` switches to the Responses API.
- With `openai-compat` and no models listed, Crush discovers them from `/v1/models`.
- Both config formats are code that runs at startup; treat a project `crushrc` like a script.
- `crush models` lists what's configured.

**Sources:** [README: custom providers](https://github.com/charmbracelet/crush/blob/main/README.md) · [Config docs](https://github.com/charmbracelet/crush/blob/main/docs/config/README.md) · [`schema.json`](https://github.com/charmbracelet/crush/blob/main/schema.json)

## Goose

The repo moved from `block/goose` to `aaif-goose/goose`.

**Where:** a JSON file per custom provider in `~/.config/goose/custom_providers/`, or `goose configure` → **Custom Providers**. **API:** `engine: openai` (Chat Completions, Responses), `anthropic` (Messages) or `ollama`.

`~/.config/goose/custom_providers/myprovider.json`:

```json
{
  "name": "myprovider",
  "engine": "openai",
  "display_name": "My Provider",
  "api_key_env": "YOUR_PROVIDER_API_KEY",
  "base_url": "https://YOUR_PROVIDER/v1",
  "models": [{ "name": "MODEL_ID", "context_limit": 128000 }],
  "supports_streaming": true,
  "requires_auth": true
}
```

Then `GOOSE_PROVIDER=myprovider GOOSE_MODEL=MODEL_ID goose session`.

Env-only alternative with the built-in OpenAI provider: `GOOSE_PROVIDER=openai`, `OPENAI_BASE_URL=https://YOUR_PROVIDER/v1`, `OPENAI_API_KEY`, `GOOSE_MODEL=MODEL_ID`. For Anthropic: `ANTHROPIC_HOST=https://YOUR_PROVIDER` (no `/v1`) and `ANTHROPIC_API_KEY`.

**Gotchas**
- **Keys in `config.yaml` are ignored.** They go in the keyring (or `secrets.yaml`), or an env var named by `api_key_env`. A 401 "No api key passed in" usually means this.
- For `engine: anthropic`, `base_url` has no `/v1`; Goose requests `v1/messages` relative to it.
- **Responses auto-switch:** with the default path, model names like `o3`, `gpt-5...` or `gpt-6...` can be sent to `/v1/responses`, even on custom endpoints. If your provider has no Responses API, pick a model alias that doesn't match.
- A 404 usually means `OPENAI_BASE_PATH` is wrong (default `v1/chat/completions`).
- `goose info -v` shows which config files are in use.

**Sources:** [Providers docs](https://github.com/aaif-goose/goose/blob/main/documentation/docs/getting-started/providers.md) · [Config files](https://github.com/aaif-goose/goose/blob/main/documentation/docs/guides/config-files.md) · [Env vars](https://github.com/aaif-goose/goose/blob/main/documentation/docs/guides/environment-variables.md) · [`declarative.rs`](https://github.com/aaif-goose/goose/blob/main/crates/goose-providers/src/declarative.rs)

## Qwen Code

**Where:** `~/.qwen/settings.json`, or env vars. **API:** Chat Completions (default), Responses (`wireApi: "responses"`), Anthropic Messages.

```json
{
  "modelProviders": {
    "openai": [
      {
        "id": "MODEL_ID",
        "name": "MODEL_ID (my provider)",
        "baseUrl": "https://YOUR_PROVIDER/v1",
        "envKey": "YOUR_PROVIDER_API_KEY"
      }
    ]
  },
  "security": { "auth": { "selectedType": "openai" } },
  "model": { "name": "MODEL_ID" }
}
```

Anthropic-compatible: put the entry under `"anthropic": [...]` and set `"selectedType": "anthropic"`.

**Env vars:** `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_MODEL`; or `ANTHROPIC_API_KEY`, `ANTHROPIC_BASE_URL`, `ANTHROPIC_MODEL`. Precedence: CLI flags, then shell env, then the first `.env` found (`.qwen/.env`, `.env`, `~/.qwen/.env`, `~/.env`), then `env` in settings.

**Gotchas**
- **The free Qwen OAuth tier ended on 2026-04-15.** It is no longer offered in `/auth`, and new requests on old cached tokens are rejected. Use a key: `/auth` → **Alibaba ModelStudio** (Coding Plan, Token Plan or API key), **Third-party Providers**, or **Custom Provider** (this config).
- `baseUrl` is the `/v1` root, not the full `/chat/completions` URL.
- `model.name` must match an `id` in `modelProviders`.
- Edits to `modelProviders` are picked up by a running session (reopen `/model`); a provider ID other than `openai`, `anthropic`, `gemini` or `vertex-ai` needs a top-level `providerProtocol` mapping, which is read only at startup.
- `security.auth.apiKey` and `security.auth.baseUrl` are deprecated; old guides use them. The `qwen auth` command was removed; use `/auth` inside the app.

**Sources:** [Auth docs](https://github.com/QwenLM/qwen-code/blob/main/docs/users/configuration/auth.md) · [Model providers docs](https://github.com/QwenLM/qwen-code/blob/main/docs/users/configuration/model-providers.md)

## Factory Droid

**Where:** `~/.factory/settings.json`, key `customModels`. **API:** set by `provider`: `generic-chat-completion-api` (Chat Completions), `openai` (Responses), `anthropic` (Messages).

```json
{
  "customModels": [
    {
      "model": "MODEL_ID",
      "displayName": "MODEL_ID (my provider)",
      "baseUrl": "https://YOUR_PROVIDER/v1",
      "apiKey": "${YOUR_PROVIDER_API_KEY}",
      "provider": "generic-chat-completion-api",
      "maxOutputTokens": 16384
    }
  ]
}
```

Anthropic-compatible: `"provider": "anthropic"` and `"baseUrl": "https://YOUR_PROVIDER"` (no `/v1`). Add `"authMode": "bearer"` if the provider wants `Authorization: Bearer` instead of `x-api-key`.

**Env vars:** `${VAR}` is expanded in `apiKey`.

**Gotchas**
- Pick the model with `/model`, under **Custom models**.
- The older `~/.factory/config.json` (snake_case: `custom_models`, `base_url`, `api_key`) still loads, but `${VAR}` expansion does not work there. Use `settings.json`.
- Custom models appear in the CLI and desktop app only.

**Sources:** [Factory docs: BYOK](https://docs.factory.com/cli/configuration/byok)

## Amp

**Where:** **Settings → Model Routing → Add → Custom URL** in Amp (workspace admins: **Workspace Model Routing**). The CLI has the same operations under `amp config model-providers`. **API:** `chat-completions` (default), `responses`, `anthropic-messages`, `google-genai`. Custom URL connections are available on every Amp tier.

| Field | Value |
| --- | --- |
| Format | `chat-completions` |
| Base URL | `https://YOUR_PROVIDER/v1` (Amp appends `/chat/completions`) |
| API key | `YOUR_PROVIDER_API_KEY` (sent as `Authorization: Bearer`) |
| Model mapping | see below |

Model mapping, one pattern per line, using Amp's `provider/model` IDs ([`configs/amp/model-mapping.txt`](configs/amp/model-mapping.txt)):

```text
# Only the models listed here go to this connection; everything else stays on Amp.
openai/gpt-5.6-sol                       # same ID on Amp and the provider
moonshotai/kimi-k3 -> MODEL_ID           # send a different model ID to the provider
```

Then pin the models in **Settings → Mode Dial → Tune Modes** (Main Agent, Oracle, Subagents) so a mode actually uses them.

For `anthropic-messages`, the base URL can be `https://YOUR_PROVIDER` or end in `/v1`; Amp requests `/v1/messages` and does not double `/v1`.

**Gotchas**
- **Mapping decides routing.** Amp tries personal connections top to bottom, then workspace connections, then Amp. A model matching no line is not served by the connection. The last matching line wins; `-pattern` excludes; `*` only at the start or end; `->` only on exact include lines.
- **Amp's IDs can differ from your provider's.** Pick the left side with the **Models** picker (Claude IDs use dashes, e.g. `anthropic/claude-opus-4-6`) and put your provider's exact ID after `->`.
- **Check Access** (or `amp config model-providers check-access --provider-model <provider/model>`) runs one short request and reports which connection served it.
- Web search, image generation, voice and orb minutes keep using Amp credits. A thread keeps the mode it started with.
- Extra headers go in the connection's **Headers** setting (`--headers` in the CLI).

**Sources:** [Amp docs: Model Routing](https://ampcode.com/docs/customize/model-routing) · [The Dial: Tune Modes](https://ampcode.com/docs/the-dial) · [Pricing](https://ampcode.com/pricing)

## Grok Build

xAI's open-source terminal coding agent (`grok`).

**Where:** `~/.grok/config.toml` (or `$GROK_HOME/config.toml`; Windows `%USERPROFILE%\.grok\config.toml`), one `[model.<id>]` table per model. **API:** `api_backend` = `chat_completions` (default), `responses` or `messages` (Anthropic Messages).

```toml
# ~/.grok/config.toml
[model.myprovider]
model = "MODEL_ID"                       # model ID sent to the provider
base_url = "https://YOUR_PROVIDER/v1"    # keep /v1 for every backend
name = "MODEL_ID (my provider)"          # shown in the model picker
env_key = "YOUR_PROVIDER_API_KEY"        # name of the env var, sent as Authorization: Bearer
api_backend = "chat_completions"         # or "responses", or "messages"
context_window = 128000

[models]
default = "myprovider"                   # the [model.<id>] key
```

Anthropic-compatible: `api_backend = "messages"`. The base URL still ends in `/v1`; Grok appends `/messages`. The `env_key` value goes out as `Authorization: Bearer`; for a provider that only accepts `x-api-key`, put the key in `extra_headers` as Grok's own Anthropic example does.

**Env vars:** the one named by `env_key` (a name, or a list of names where the first non-empty one wins). `GROK_MODELS_BASE_URL` is a different mechanism: it replaces Grok's whole model list with `{base}/models` and authenticates that fetch with `XAI_API_KEY` only.

**Gotchas**
- **Credential order per model:** `api_key`, then `env_key`, then your `grok login` session, then `XAI_API_KEY`. A custom model with its own `env_key` works while you stay signed in to xAI for Grok's own models.
- A new model without `context_window` is treated as 200,000 tokens, which decides when auto-compaction runs.
- On `responses`, Grok asks for a `concise` reasoning summary. Set `reasoning_summary = "none"` for gateways that reject `reasoning.summary`.
- The `web_search` tool runs on its own model (`[models] web_search`); server-side search only runs on a model with `supports_backend_search = true`.
- An enterprise `requirements.toml` can pin the allowed models; a local `[model.<id>]` can't widen that list.
- `grok models` lists custom models too. Switch with `/model myprovider` or `grok -m myprovider`.

**Sources:** [Grok Build settings reference](https://docs.x.ai/build/settings/reference) · [Custom models guide](https://github.com/xai-org/grok-build/blob/main/crates/codegen/xai-grok-pager/docs/user-guide/11-custom-models.md) · [Config reference](https://github.com/xai-org/grok-build/blob/main/crates/codegen/xai-grok-pager/docs/user-guide/26-config-reference.md)

## DeepSeek Harness

DeepSeek's agent harness (`dsh`), in developer preview with breaking changes announced.

**Where:** web UI **Settings → Models → Add model provider → Custom model API**, saved to `$DSH_HOME/profiles/<profile>/cordis.patch.yml` (`~/.dsh/profiles/web/cordis.patch.yml` for `dsh web`). **API:** OpenAI Chat Completions, OpenAI Responses or Anthropic Messages (`openai-completions`, `openai-responses`, `anthropic-messages`), one per provider.

In the UI: **Provider ID** (lowercase), display name, **Base URL** (`https://YOUR_PROVIDER/v1`), **API protocol**, **API key**, and at least one model (**Fetch available models** or type the IDs). The same thing as a file ([`configs/deepseek-harness/cordis.patch.yml`](configs/deepseek-harness/cordis.patch.yml)):

```yaml
# $DSH_HOME/profiles/web/cordis.patch.yml
- id: llm-pi-ai
  config:
    providers:
      myprovider:
        apiKeyEnv: YOUR_PROVIDER_API_KEY
        api: openai-completions
        baseURL: https://YOUR_PROVIDER/v1
        models:
          - id: MODEL_ID
```

For an Anthropic-compatible endpoint, add a second provider with `api: anthropic-messages` and the provider's Anthropic base URL (no `/v1`; dsh sends requests through the same pi-ai library as Pi).

**Env vars:** the one `apiKeyEnv` names. A key typed into the Models page is stored in `$DSH_HOME/.credentials.yaml` and never shown again.

**Gotchas**
- **The Provider ID is permanent.** To rename, add a new provider and delete the old one.
- **One protocol per provider.** A gateway that serves Chat Completions and Anthropic Messages needs two providers.
- **A gateway that refuses every request** with a working key usually objects to OpenAI-only request details: set `compat.supportsDeveloperRole: false` and `compat.maxTokensField: max_tokens` on the provider.
- A Cordis override replaces the whole entry config. When editing the file, keep the other providers in the same entry.
- Hand-entered models get no **Effort** menu until you declare `reasoningEfforts`. DeepSeek V4 behind a gateway also needs `compat.thinkingFormat: deepseek` before `off` stops it thinking.
- Changes apply on the next request; no restart.

**Sources:** [Configure models](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.md) · [`dsh-llm-pi-ai` reference](https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/llm/llm-pi-ai/README.md)

## Command Code

**Where:** `/connect` → **(BYOK) Add your own provider**, or `~/.commandcode/providers.json` (edits apply live). **API:** `api` = `openai-completions` (default), `openai-responses` or `anthropic-messages`.

```json
{
  "provider": {
    "myprovider": {
      "name": "My Provider",
      "baseURL": "https://YOUR_PROVIDER/v1",
      "apiKey": "$YOUR_PROVIDER_API_KEY",
      "api": "openai-completions",
      "models": {
        "MODEL_ID": { "contextWindow": 128000 }
      }
    }
  }
}
```

Anthropic-compatible: `"api": "anthropic-messages"`. Command Code adds `/v1` to the base URL if it's missing.

**Env vars:** `apiKey` takes a reference, not a key: `"$NAME"` or `"{env:NAME}"`, `"!command"` (its output), or `false` for keyless local servers. A key pasted in `/connect` goes to `~/.commandcode/auth.json` (mode 0600) and wins over the file's reference.

**Gotchas**
- **A raw key written into `providers.json` is refused** with a warning.
- `"MODEL_ID": {}` is a complete model entry; add `contextWindow` at least. `/connect` imports the provider's model list for you.
- Pick the model with `/model`; each provider has its own section. While a BYOK model is active, sub-agents and compaction use it too.
- BYOK requests go from your machine straight to the provider. `cmd --local-only` (or `CMD_LOCAL_ONLY=1`) also turns off telemetry.

**Sources:** [Command Code docs: BYOK providers](https://commandcode.ai/docs/byok)

## jcode

**Where:** `jcode provider add`, which writes `[providers.<name>]` to `~/.jcode/config.toml`. **API:** OpenAI-compatible (Chat Completions). Anthropic goes through jcode's built-in Anthropic API key or Claude sign-in, not a custom profile.

```sh
printf '%s' "$YOUR_PROVIDER_API_KEY" | jcode provider add myprovider \
  --base-url https://YOUR_PROVIDER/v1 \
  --model MODEL_ID \
  --api-key-stdin \
  --set-default

jcode --provider-profile myprovider auth-test --no-tool-smoke
```

**Env vars:** `--api-key-stdin` stores the key in jcode's private config dir (for example `~/.config/jcode/provider-myprovider.env`). `--api-key-env NAME` reads it from an env var instead; `--no-api-key` is for localhost servers.

**Gotchas**
- Prefer `--api-key-stdin` over `--api-key`, which leaves the key in your shell history.
- `--set-default` makes the profile the startup provider and model. `--overwrite` replaces an existing profile of the same name.
- `--context-window` sets the window for models jcode doesn't know; `--model-catalog` lists the provider's `/models`.
- Providers that want the key in a header other than `Authorization`: `--auth api-key --auth-header <name>`.
- Fireworks, Novita and MiniMax have built-in presets (`jcode login --provider <name>`).

**Sources:** [OAUTH.md: OpenAI-compatible API-key providers](https://github.com/1jehuang/jcode/blob/master/OAUTH.md) · [`src/cli/args.rs`](https://github.com/1jehuang/jcode/blob/master/src/cli/args.rs)

## Docker Agent

Docker's runtime for YAML-defined agents (formerly cagent), run as `docker agent`.

**Where:** a `providers` block in the agent YAML, or in `~/.config/cagent/config.yaml` to make it available to every agent and command. **API:** `api_type` = `openai_chatcompletions` or `openai_responses`; `provider: anthropic` for Anthropic Messages.

```yaml
# agent.yaml  ->  docker agent run agent.yaml
providers:
  myprovider:
    base_url: https://YOUR_PROVIDER/v1
    token_key: YOUR_PROVIDER_API_KEY     # name of the env var
    api_type: openai_chatcompletions

agents:
  root:
    model: myprovider/MODEL_ID
    description: A helpful assistant
    instruction: You are a helpful assistant.
```

Anthropic-compatible: `provider: anthropic` and `base_url: https://YOUR_PROVIDER` (no `/v1`; the Anthropic SDK appends `/v1/messages`). The key is sent as `x-api-key`. The interactive route for a global provider is `docker agent setup` → **Custom OpenAI-compatible endpoint**.

**Env vars:** the one `token_key` names. Docker Agent looks it up in the environment, Compose secrets under `/run/secrets/`, `~/.config/cagent/.env` (read on every run), then credential helpers; `--env-from-file` adds a file.

**Gotchas**
- **Without `api_type`, the model name decides:** gpt-4.1, gpt-5, o-series and Codex names go to `openai_responses`, everything else to Chat Completions. Set it explicitly.
- **`model: auto` never picks a custom provider.** Reference it as `myprovider/MODEL_ID` in the agent, with `--model` or `default_model`.
- A provider with a `base_url` bypasses any configured models gateway and authenticates with its own `token_key`.
- A custom Anthropic `base_url` receives `ANTHROPIC_API_KEY` when `token_key` is unset. Only point it at hosts you trust with that key.
- An agent file's provider wins over a global one with the same name.

**Sources:** [Provider definitions](https://docker.github.io/docker-agent/providers/custom/) · [Managing secrets](https://docker.github.io/docker-agent/guides/secrets/) · [Anthropic: Claude access paths](https://docker.github.io/docker-agent/providers/anthropic/)

## Zed

**Where:** `~/.config/zed/settings.json` (Windows `%APPDATA%\Zed\settings.json`), or **Agent Settings → LLM Providers → Add Provider**. **API:** Chat Completions (default), Responses (`chat_completions: false`), Anthropic Messages (`anthropic_compatible`).

```json
{
  "language_models": {
    "openai_compatible": {
      "your-provider": {
        "api_url": "https://YOUR_PROVIDER/v1",
        "available_models": [
          {
            "name": "MODEL_ID",
            "display_name": "My model",
            "max_tokens": 128000,
            "max_output_tokens": 16384,
            "capabilities": {
              "tools": true,
              "images": false,
              "parallel_tool_calls": false,
              "prompt_cache_key": false
            }
          }
        ]
      }
    },
    "anthropic_compatible": {
      "your-provider-anthropic": {
        "api_url": "https://YOUR_PROVIDER",
        "available_models": [
          { "name": "MODEL_ID", "max_tokens": 200000, "max_output_tokens": 32000 }
        ]
      }
    }
  }
}
```

**Env vars:** the key's env var name comes from the provider ID: upper snake case plus `_API_KEY`. `your-provider` reads `YOUR_PROVIDER_API_KEY`; `your-provider-anthropic` reads `YOUR_PROVIDER_ANTHROPIC_API_KEY`. A key typed into the UI goes to the system keychain. Don't put keys in `settings.json`; there is no field for them.

**Gotchas**
- `api_url` includes `/v1` for `openai_compatible` and leaves it out for `anthropic_compatible` (Zed calls `{api_url}/v1/messages`).
- `max_tokens` is the context window, not the output cap. The output cap is `max_output_tokens`.
- If the provider wants `max_tokens` instead of `max_completion_tokens`, add `"max_tokens_parameter": true` to `capabilities`.

**Sources:** [Zed docs: use your own API access](https://github.com/zed-industries/zed/blob/main/docs/src/ai/use-api-access.md) · [`language_model.rs`](https://github.com/zed-industries/zed/blob/main/crates/settings_content/src/language_model.rs)

## Cursor (BYOK)

**Where:** **Cursor Settings → Models** (UI only). **API:** OpenAI-compatible, through the OpenAI key slot. There is no base-URL override for the Anthropic or Google slots.

1. Paste your provider key into the **OpenAI API Key** field and turn on **Use OpenAI API key**.
2. Turn on **Override OpenAI Base URL** and enter `https://YOUR_PROVIDER/v1`.
3. Add a custom model named `MODEL_ID` and enable it.

**Env vars:** none.

**Gotchas**
- **The endpoint must be public HTTPS.** Every BYOK request goes through Cursor's servers, so `localhost` needs a tunnel.
- **Chat and Agent only.** Tab completion keeps using Cursor's own models.
- **The override applies to every non-Claude, non-Gemini model**, including Cursor's built-in ones, which then fail. Turn it off to use them again.
- **Model names:** a name starting with `claude-` is routed to the Anthropic slot, and names that match built-in models are taken by Cursor's routing. Use your provider's exact ID; if it collides, your provider may offer an alias.
- Agent mode has sent Responses-style payloads to custom endpoints (a known issue in early 2026, per Cursor staff). A provider that serves both `/v1/chat/completions` and `/v1/responses` is the safe choice.
- BYOK needs a paid Cursor plan. Teams and Enterprise admins can turn personal API keys off.

**Sources:** [Cursor docs: API keys](https://cursor.com/help/models-and-usage/api-keys) · [Release notes 3.20 (Base URL override switch)](https://cursor.com/docs/release-notes) · [Cursor staff on public endpoints](https://forum.cursor.com/t/156489)

## GitHub Copilot in VS Code (custom endpoint)

**Where:** VS Code **Chat: Manage Language Models → Add Models → Custom Endpoint**, which opens `chatLanguageModels.json`. **API:** Chat Completions, Responses or Anthropic Messages (`apiType`).

```json
[
  {
    "name": "YOUR_PROVIDER",
    "vendor": "customendpoint",
    "apiKey": "${input:yourProviderApiKey}",
    "apiType": "chat-completions",
    "models": [
      {
        "id": "MODEL_ID",
        "name": "MODEL_ID",
        "url": "https://YOUR_PROVIDER/v1/chat/completions",
        "toolCalling": true,
        "vision": false,
        "maxInputTokens": 128000,
        "maxOutputTokens": 16000
      }
    ]
  }
]
```

For an Anthropic-compatible endpoint: `"apiType": "messages"` and `"url": "https://YOUR_PROVIDER/v1/messages"`. For Responses: `"apiType": "responses"` and `.../v1/responses`.

**Env vars:** none. `${input:...}` prompts once and keeps the key in VS Code secret storage.

**Gotchas**
- **This replaced the "OpenAI Compatible" provider.** The `github.copilot.chat.customOAIModels` setting is deprecated; old guides that use it are out of date.
- Give the full endpoint URL. If the URL has no `/chat/completions`, `/responses` or `/messages`, VS Code appends one and may insert `/v1`.
- **Agent mode needs `"toolCalling": true`**; models without it are hidden from the agent picker.
- `maxInputTokens + maxOutputTokens` must fit in the model's context window.
- BYOK works without a Copilot plan for chat. Inline completions, embeddings and semantic search still need GitHub. Copilot Business/Enterprise admins control the **Bring Your Own Language Model Key in VS Code** policy.
- Requests go out from your machine, so a local server (Ollama, LM Studio, LiteLLM) works.

**Sources:** [VS Code docs: language models](https://code.visualstudio.com/docs/agent-customization/language-models) · [docs source](https://github.com/microsoft/vscode-docs/blob/main/docs/agent-customization/language-models.md)

## GitHub Copilot CLI

**Where:** environment variables, set before starting `copilot`. **API:** `COPILOT_PROVIDER_TYPE` = `openai` (Chat Completions, the default), `azure` or `anthropic`.

```sh
# configs/github-copilot-cli/env.sh
export COPILOT_PROVIDER_BASE_URL="https://YOUR_PROVIDER/v1"
export COPILOT_PROVIDER_API_KEY="$YOUR_PROVIDER_API_KEY"
export COPILOT_MODEL="MODEL_ID"
```

Anthropic-compatible: `COPILOT_PROVIDER_TYPE=anthropic` and `COPILOT_PROVIDER_BASE_URL=https://YOUR_PROVIDER` (no `/v1`, as in GitHub's Anthropic example).

**Env vars:** also `COPILOT_PROVIDER_BEARER_TOKEN`, `COPILOT_PROVIDER_WIRE_API`, `COPILOT_PROVIDER_MODEL_ID` (the well-known model name used for capabilities and token limits), `COPILOT_PROVIDER_WIRE_MODEL` (the name sent to the provider), `COPILOT_PROVIDER_MAX_PROMPT_TOKENS`, `COPILOT_PROVIDER_MAX_OUTPUT_TOKENS`. `--model` overrides `COPILOT_MODEL`.

**Gotchas**
- The model must support **tool calling and streaming**, or the CLI returns an error. GitHub recommends a context window of at least 128k tokens.
- If your provider's model name is not one Copilot knows, set `COPILOT_PROVIDER_MAX_PROMPT_TOKENS` and `COPILOT_PROVIDER_MAX_OUTPUT_TOKENS` yourself.
- `COPILOT_OFFLINE=true` stops the CLI from contacting GitHub, but prompts still go to a remote provider if the base URL is remote.
- `copilot help providers` prints more examples.

**Sources:** [GitHub docs: add LLM models to Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models)

## JetBrains AI Assistant and Junie CLI

**AI Assistant (IDE):** **Settings → Tools → AI Assistant → Providers & API keys → Third-party AI providers**, **Provider** = **OpenAI-compatible**. Fill in **URL** and **API Key**, turn on **Tool calling** if the model supports it, then **Test Connection** and **Apply**. Under **Models Assignment**, choose the model for core features and set **Context window**. There is no custom Anthropic-compatible endpoint here, only the official Anthropic key.

**Junie CLI:** one JSON file per model profile in `~/.junie/models/` (or `.junie/models/` in a project). The file name is the profile ID.

```json
{
  "baseUrl": "https://YOUR_PROVIDER/v1/chat/completions",
  "id": "MODEL_ID",
  "apiType": "OpenAICompletion",
  "apiKey": "${YOUR_PROVIDER_API_KEY}"
}
```

Run it with `junie --model custom:<file-name-without-.json>`. `apiType` can be `OpenAICompletion`, `OpenAIResponses`, `Anthropic` or `Google`.

**Gotchas**
- Junie's `baseUrl` is the complete endpoint URL; Junie does not append a path.
- A missing `${VAR}` makes the profile fail to load.
- The Junie IDE plugin does not support your own key; the CLI does.

**Sources:** [AI Assistant: providers and API keys](https://www.jetbrains.com/help/ai-assistant/settings-reference-providers-and-api-keys.html) · [AI Assistant: custom models](https://www.jetbrains.com/help/ai-assistant/use-custom-models.html) · [Junie: custom LLM models](https://junie.jetbrains.com/docs/custom-llm-models.html)

## NanoClaw

A container-isolated personal agent that runs Claude Code through the Claude Agent SDK.

**Where:** env vars set before setup (`bash nanoclaw.sh`). **API:** Anthropic Messages only.

```sh
# No /v1: the Claude Agent SDK appends /v1/messages itself.
export NANOCLAW_ANTHROPIC_BASE_URL="https://YOUR_PROVIDER"
export NANOCLAW_ANTHROPIC_AUTH_TOKEN="$YOUR_PROVIDER_API_KEY"
bash nanoclaw.sh

# Model, per agent group (or NANOCLAW_DEFAULT_MODEL=MODEL_ID in the host .env for every group):
ncl groups config update --id <group-id> --model MODEL_ID
ncl groups restart --id <group-id>
```

**Env vars:** setup stores the token in the credential vault as a header injection keyed to your provider's hostname. The agent container only sees `ANTHROPIC_BASE_URL` and the placeholder `ANTHROPIC_AUTH_TOKEN=gateway-managed`; the real key is added on the wire.

**Gotchas**
- **No OpenAI-compatible option in the default Claude provider.** For other APIs, the `/add-opencode` skill switches an agent group to OpenCode, which then takes an [OpenCode provider block](#opencode).
- A group with no model asks for a Claude model by name, so the endpoint must serve that ID, or set a model as above.
- The README's `.env` route (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`) is meant for one-off experiments; the setup variables keep the key out of the container.
- `NANOCLAW_DEFAULT_MODEL` is read when a group's container starts, so a change applies on the next start without a host restart.

**Sources:** [NanoClaw docs: credentials](https://docs.nanoclaw.dev/operate/credentials) · [Environment variables](https://docs.nanoclaw.dev/reference/environment-variables) · [README FAQ](https://github.com/nanocoai/nanoclaw/blob/main/README.md) · [Release 2.4 notes (`NANOCLAW_DEFAULT_MODEL`)](https://github.com/nanocoai/nanoclaw/blob/main/docs/release-2.4-update.md)

## Octop

Tencent Cloud's self-hosted multi-user assistant (web dashboard plus Feishu, DingTalk, WeCom, QQ, WeChat, Telegram, Discord).

**Where:** dashboard, as admin: **Model Management → Custom Providers → New Provider**. CLI: `octop provider create`. **API:** **Type** = **OpenAI Compatible**, **Anthropic** or **Bedrock**.

| Field | Value |
| --- | --- |
| Name | `myprovider` |
| Type | OpenAI Compatible |
| Base URL | `https://YOUR_PROVIDER/v1` |
| API Key | `YOUR_PROVIDER_API_KEY` |
| Models | **Fetch models**, or add `MODEL_ID` by hand |

Then **Test Connection**, save, and **Set as preferred** on the model so agents use it by default ([`configs/octop/custom-provider.txt`](configs/octop/custom-provider.txt)).

**Env vars:** none; the key is stored with the provider.

**Gotchas**
- **Fetch models** works only for OpenAI Compatible providers. Fetched models start disabled; enable the ones you want.
- Live token usage starts **off** for custom providers because some gateways reject the stream-usage option and the chat fails. Turn it on only if yours accepts it.
- Per model you can set context window, max tokens and reasoning support under the provider's model management.

**Sources:** [Octop user guide §4 (Chinese)](https://github.com/TencentCloud/Octop/blob/main/docs/user-guide.md) · [CLI reference](https://github.com/TencentCloud/Octop/blob/main/docs/cli.md) · [`CustomProviderModal.tsx`](https://github.com/TencentCloud/Octop/blob/main/dashboard/src/pages/Settings/Models/components/modals/CustomProviderModal.tsx) · [`en.json` labels](https://github.com/TencentCloud/Octop/blob/main/dashboard/src/locales/en.json)

## Rakazo

Self-hosted persistent AI teammates with their own computers (web, desktop, iOS, Android).

**Where:** the deployment's `.env`, then **Settings → Models → OpenAI-compatible** (also offered as **Connect a model** at onboarding). **API:** Chat Completions.

```sh
# .env of your Rakazo deployment, then recreate the stack
RAKAZO_OPENAI_COMPAT_ALLOW_PUBLIC=1
```

| Field | Value |
| --- | --- |
| OpenAI-compatible server URL | `https://YOUR_PROVIDER/v1` |
| Model id | `MODEL_ID` (or **Models from server**) |
| API key | `YOUR_PROVIDER_API_KEY` (optional) |
| Advanced | **Supports images** on if the model takes images |

**Env vars:** `RAKAZO_OPENAI_COMPAT_ALLOW_PUBLIC=1` on the deployment. The key itself is entered per user in the UI.

**Gotchas**
- **Public endpoints are blocked by default.** Any public hostname needs the flag above and HTTPS. Literal private IPs, loopback and `host.docker.internal` work without it.
- **Supports images** is off for new connections. Without it, attachments and the screenshot computer tools are unavailable.
- Turn on **Supports thinking** only if the endpoint accepts the standard `reasoning_effort` parameter.

**Sources:** [Self-hosting guide](https://github.com/elie222/rakazo/blob/main/docs/self-host.md) · [`pi-openai-compatible-provider.ts`](https://github.com/elie222/rakazo/blob/main/packages/adapters/src/pi-openai-compatible-provider.ts)

## nanoMuse

An open-source personal agent for phone, desktop and web, with a runtime you can host yourself.

**Where:** web console **Connections → Chat model → Local or your own endpoint → Add an endpoint**; desktop **Settings → Account → Any OpenAI-compatible endpoint → Add an endpoint**; phone **Settings → Providers → Add** → **Custom**. On a runtime of your own, `[llm]` in `./config/config.toml` or `~/.nanomuse/config.toml`. **API:** `provider = "openai"` (Chat Completions) or `"openai_responses"` (Responses).

```toml
[llm]
provider = "openai"
model    = "MODEL_ID"
base_url = "https://YOUR_PROVIDER/v1"
api_key  = "${YOUR_PROVIDER_API_KEY}"
```

In the apps: **Base URL** `https://YOUR_PROVIDER/v1`, **API key**, and leave **Models** empty if the endpoint lists them at `/models` (otherwise give the IDs, comma-separated).

**Env vars:** `${NAME}` in `api_key`. Keys entered in the web console go to the runtime's vault.

**Gotchas**
- **A custom endpoint covers chat only** until you set it for the other jobs. The screen-operating row ("hands") needs a model that sees images; pictures and clips need their own model IDs.
- A base URL saved from the apps without a path gets `/v1` appended.
- If the endpoint silently ignores `tools`, set `tool_mode = "prompt"`; `auto` only falls back when the endpoint rejects them.
- Several custom endpoints can exist side by side on desktop and web; the phones keep one slot per provider.
- `nanomuse config show` prints the effective settings with secrets masked.

**Sources:** [Bring your own key](https://github.com/nano-muse/nanoMuse/blob/main/docs/own-key.md) · [Configuration](https://github.com/nano-muse/nanoMuse/blob/main/docs/configuration.md)

## Magpie

Not an agent: a desktop provider manager that sets the model for Claude Code, Codex, OpenCode, Gemini CLI and many other agents through one local gateway (`127.0.0.1:3425`) that translates between OpenAI Chat, Responses, Anthropic Messages and Gemini.

**Where:** **Providers → Add provider** in the app, `magpie provider add` in a terminal, or an "Add to magpie" import link. **API (provider side):** `chat` (Chat Completions), `responses`, `anthropic` (Messages), `gemini`.

```sh
magpie provider add "My Provider" url=https://YOUR_PROVIDER/v1 anthropic=https://YOUR_PROVIDER key=YOUR_PROVIDER_API_KEY
magpie claude myprovider/MODEL_ID      # or pick per agent on the Agents page
```

Import link format ([`configs/magpie/import-link.txt`](configs/magpie/import-link.txt)); everything after `#` stays in the browser:

```text
https://usemagpie.ai/import#name=My%20Provider&id=myprovider&chat=https%3A%2F%2FYOUR_PROVIDER%2Fv1&anthropic=https%3A%2F%2FYOUR_PROVIDER&models=MODEL_ID
```

| Parameter | Value |
| --- | --- |
| `name` or `preset` | display name (max 80 chars), or a built-in preset ID |
| `chat` | Chat Completions base URL, ending in `/v1` |
| `responses` | Responses base URL, ending in `/v1` |
| `anthropic` | Anthropic base URL, **without** `/v1` |
| `gemini` | Gemini API base URL, ending in `/v1beta` |
| `key` | the user's key; leave it out of public links |
| `models` | comma-separated IDs; default is the provider's `/v1/models` |
| `id`, `catalog`, `website`, `keys`, `icon` | optional: agent-facing ID, models.dev metadata, links, icon |

**Gotchas**
- Without a preset, at least one of `chat`, `responses`, `anthropic`, `gemini` is required. Base URLs must be HTTPS (plain HTTP only for localhost, private addresses and `*.local`) and can't carry a query, fragment or credentials.
- Nothing is saved until the user confirms the import in Magpie.
- Agents pick models as `provider/model` and never see the vendor key or URL.
- The app scheme `magpie://import?...` takes the same parameters as a query string.

**Sources:** [Magpie docs: Add to magpie](https://usemagpie.ai/docs/import) · [Reference: providers and the gateway](https://github.com/yetone/magpie/blob/main/docs/reference.md) · [README](https://github.com/yetone/magpie/blob/main/README.md)

## Gemini CLI

Not supported natively. `GOOGLE_GEMINI_BASE_URL` changes the host (HTTPS unless it's localhost), but requests still use the Gemini API format (`generateContent`), so it only works with a server that speaks Gemini's API. There is no OpenAI- or Anthropic-compatible option: the feature request for one ([#23385](https://github.com/google-gemini/gemini-cli/issues/23385)) was closed without shipping, and the client still has no OpenAI or Anthropic code path (re-checked on the 0.66 nightly, 2026-10-15).

To use an OpenAI- or Anthropic-compatible provider anyway, put a local gateway that translates into Gemini's format in between. [Magpie](#magpie)'s gateway does (`GOOGLE_GEMINI_BASE_URL=http://127.0.0.1:3425`, `GEMINI_API_KEY=magpie`).

**Sources:** [Configuration reference](https://github.com/google-gemini/gemini-cli/blob/main/docs/reference/configuration.md) · [`contentGenerator.ts`](https://github.com/google-gemini/gemini-cli/blob/main/packages/core/src/core/contentGenerator.ts) · [Issue #23385](https://github.com/google-gemini/gemini-cli/issues/23385) · [Magpie README](https://github.com/yetone/magpie/blob/main/README.md)

---

## check.sh: test a provider first

A small bash script (curl only, no dependencies) that tells you whether a base URL, key and model ID work before you edit any agent config.

```sh
curl -fsSLO https://raw.githubusercontent.com/henrikdukefoss/agent-provider-configs/main/check.sh
chmod +x check.sh

./check.sh https://openrouter.ai/api/v1                        # lists models (asks for the key, input hidden)
API_KEY=... ./check.sh --model MODEL_ID https://YOUR_PROVIDER/v1  # also sends one 16-token request
API_KEY=... ./check.sh --anthropic https://YOUR_PROVIDER          # Anthropic-style base URL (no /v1)
```

Example against a public endpoint with a made-up key:

```text
$ API_KEY=sk-invalid ./check.sh https://api.openai.com/v1
GET https://api.openai.com/v1/models
HTTP 401
result: the endpoint exists but rejected the key (HTTP 401).
```

The key is read from `$API_KEY` or a hidden prompt, passed to curl on stdin (so it doesn't show in the process list), sent only to the URL you give, and never printed. `--model` costs one tiny request on your account.

## How this was checked

- **Claude Code, OpenCode and Codex CLI**: the exact files in `configs/` were run with the real CLIs (Claude Code 2.1.296, OpenCode 1.19.0, codex-cli 0.162.1) against a local mock server that logs each request. Results:

  | Config | Request the CLI made |
  | --- | --- |
  | `configs/opencode/opencode.json` (`@ai-sdk/openai-compatible`) | `POST /v1/chat/completions`, `Authorization: Bearer ...` |
  | same, with `@ai-sdk/openai` | `POST /v1/responses`, `Authorization: Bearer ...` |
  | `configs/opencode/opencode.anthropic.json` | `POST /v1/messages`, `x-api-key: ...` |
  | `configs/codex/config.toml` with `--strict-config` | `POST /v1/responses`, `Authorization: Bearer ...` |
  | same, with `wire_api = "chat"` | refused to start: "`wire_api = "chat"` is no longer supported" |
  | Claude Code, `ANTHROPIC_BASE_URL` without `/v1` | `POST /v1/messages` |
  | Claude Code, `ANTHROPIC_BASE_URL` with `/v1` | `POST /v1/v1/messages` (a 404 on a real provider) |
  | Claude Code, `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_API_KEY` / both | `Authorization: Bearer` / `x-api-key` / both headers |
  | `configs/claude-code/settings.json` (`env` + `apiKeyHelper`) | `POST /v1/messages` with both headers |

- **Every other agent**: keys and paths were checked against the agent's current docs and, where linked, its source code on the default branch. These configs were not run. They are syntax-checked (JSON, YAML, bash).
- **Provider presets**: taken from each provider's own docs page, linked in the table.

Formats change often. If something here is out of date, a PR with a source link fixes it for everyone.

## Related guides

Written by Standard Compute, which maintains this repo:

- [AI agent setup guides](https://standardcompute.com/integrations): one page per agent for pointing it at an OpenAI-compatible base URL.
- [OpenCode config generator](https://standardcompute.com/tools/agent-config): builds an `opencode.json` provider block for any compatible provider.
- [Fixing "model does not exist" (404)](https://standardcompute.com/fix/model-not-found) and [Fixing "Incorrect API key" (401)](https://standardcompute.com/fix/incorrect-api-key): the two errors most custom-provider setups hit first.
- [Tool calling, MCP, streaming and caching through an LLM gateway](https://standardcompute.com/llm-gateway-compatibility): which features survive a proxy and which don't.
- [AI coding agent monthly costs](https://standardcompute.com/ai-coding-agent-monthly-cost): measured spend per agent. Also in: [Español](https://standardcompute.com/costo-agente-de-codificacion-ia) · [Português](https://standardcompute.com/custo-agente-de-codificacao-ia) · [Français](https://standardcompute.com/cout-agent-de-codage-ia) · [日本語](https://standardcompute.com/ai-coding-agent-hiyou) · [한국어](https://standardcompute.com/ai-coding-agent-biyong) · [简体中文](https://standardcompute.com/ai-coding-agent-feiyong) · [Norsk](https://standardcompute.com/kostnad-ai-kodeagent)

## Contributing

PRs are welcome, especially when an agent renames a key or moves a file. Please link the docs page or source file for each change and say whether you ran it. See [CONTRIBUTING.md](CONTRIBUTING.md).

## About

Maintained by [Standard Compute](https://standardcompute.com), which is one of the providers in the table. The configs are provider-neutral: every example uses placeholders, and any OpenAI- or Anthropic-compatible provider fits them.

MIT License. Agent and provider names belong to their owners.
