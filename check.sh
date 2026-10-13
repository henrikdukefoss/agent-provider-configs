#!/usr/bin/env bash
# check.sh - test an OpenAI- or Anthropic-compatible provider before you point an agent at it.
#
#   API_KEY=... ./check.sh https://openrouter.ai/api/v1              # OpenAI-style: GET {base}/models
#   API_KEY=... ./check.sh --anthropic https://openrouter.ai/api     # Anthropic-style: GET {base}/v1/models
#   API_KEY=... ./check.sh --model MODEL_ID https://openrouter.ai/api/v1   # also send one tiny request
#
# The key is read from $API_KEY, or asked for without echo if $API_KEY is empty.
# It is sent only to the URL you give and is never printed. Needs bash and curl.

set -u

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

mode="openai"
base=""
model=""
while [ $# -gt 0 ]; do
  case "$1" in
    --anthropic) mode="anthropic" ;;
    --openai) mode="openai" ;;
    --model) shift; model="${1:-}"; [ -n "$model" ] || usage ;;
    -h|--help) usage ;;
    -*) echo "unknown option: $1" >&2; usage ;;
    *) base="$1" ;;
  esac
  shift
done
[ -n "$base" ] || usage
command -v curl >/dev/null 2>&1 || { echo "check.sh needs curl" >&2; exit 2; }

base="${base%/}"
key="${API_KEY:-}"
if [ -z "$key" ]; then
  if [ -t 0 ]; then
    printf 'API key (input hidden, empty for none): ' >&2
    stty -echo 2>/dev/null; IFS= read -r key; stty echo 2>/dev/null; printf '\n' >&2
  fi
fi

if [ "$mode" = "anthropic" ]; then
  case "$base" in
    */v1) echo "warning: Anthropic-style base URLs usually go WITHOUT /v1 (clients append /v1/messages)." >&2
          echo "         Checking ${base}/v1/models anyway; expect a 404 if the warning applies." >&2 ;;
  esac
  url="${base}/v1/models"
else
  url="${base}/models"
fi

tmp="$(mktemp "${TMPDIR:-/tmp}/check.XXXXXX")" || exit 2
trap 'rm -f "$tmp"' EXIT

# Headers go through a here-doc on stdin so the key never appears in the process list.
if [ "$mode" = "anthropic" ]; then
  code="$(curl -sS -m 20 -o "$tmp" -w '%{http_code}' -H @- "$url" <<EOF
x-api-key: ${key}
Authorization: Bearer ${key}
anthropic-version: 2023-06-01
EOF
)"
else
  code="$(curl -sS -m 20 -o "$tmp" -w '%{http_code}' -H @- "$url" <<EOF
Authorization: Bearer ${key}
EOF
)"
fi
rc=$?

echo "GET $url"
if [ $rc -ne 0 ]; then
  echo "result: no HTTP response (curl exit $rc). Check the host name, scheme and network." >&2
  exit 1
fi
echo "HTTP $code"

ids="$(tr ',' '\n' < "$tmp" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
count="$(printf '%s\n' "$ids" | grep -c . || true)"

case "$code" in
  2*)
    if [ "$count" -gt 0 ]; then
      echo "models: $count"
      printf '%s\n' "$ids" | head -n 25 | sed 's/^/  /'
      [ "$count" -gt 25 ] && echo "  ... and $((count - 25)) more"
      echo "ok: the endpoint answers. Use one of these IDs as the model name in your agent."
    else
      echo "ok: HTTP $code, but no model IDs found in the response:"
      head -c 400 "$tmp"; echo
    fi
    [ -n "$model" ] || { echo "note: some providers list models without checking the key. Add --model ID to send one real request."; exit 0; }
    ;;
  401|403)
    echo "result: the endpoint exists but rejected the key (HTTP $code)." ;;
  404)
    echo "result: nothing at this path (HTTP 404)."
    if [ "$mode" = "openai" ]; then
      case "$base" in
        */v1|*/v[0-9]) echo "hint: some providers do not implement GET /models even when chat works." ;;
        *) echo "hint: OpenAI-style base URLs usually end in /v1 (for example https://openrouter.ai/api/v1)." ;;
      esac
    else
      echo "hint: some Anthropic-compatible endpoints only implement POST /v1/messages, not /v1/models."
    fi ;;
  *)
    echo "result: unexpected HTTP $code." ;;
esac
if [ "${code#2}" = "$code" ]; then
  echo "response (first 400 bytes):"
  head -c 400 "$tmp"; echo
  [ -n "$model" ] || exit 1
  echo "Trying the request anyway, because --model was given."
fi

# --model: one request with max 16 output tokens, to prove the key, model name and API format.
if [ "$mode" = "anthropic" ]; then
  url="${base}/v1/messages"
  body='{"model":"'"$model"'","max_tokens":16,"messages":[{"role":"user","content":"Reply with OK"}]}'
  code="$(curl -sS -m 60 -o "$tmp" -w '%{http_code}' -H @- -H 'content-type: application/json' --data-binary "$body" "$url" <<EOF
x-api-key: ${key}
Authorization: Bearer ${key}
anthropic-version: 2023-06-01
EOF
)"
else
  url="${base}/chat/completions"
  body='{"model":"'"$model"'","max_tokens":16,"messages":[{"role":"user","content":"Reply with OK"}]}'
  code="$(curl -sS -m 60 -o "$tmp" -w '%{http_code}' -H @- -H 'content-type: application/json' --data-binary "$body" "$url" <<EOF
Authorization: Bearer ${key}
EOF
)"
fi
echo
echo "POST $url  (model $model, max 16 output tokens)"
echo "HTTP ${code:-none}"
case "$code" in
  2*) echo "ok: the key, model name and API format work."; exit 0 ;;
  401|403) echo "result: key rejected (HTTP $code)." ;;
  404) echo "result: HTTP 404. Wrong path or unknown model; check the base URL and the model ID." ;;
  *) echo "result: HTTP $code." ;;
esac
echo "response (first 400 bytes):"
head -c 400 "$tmp"; echo
exit 1
