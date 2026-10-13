# Contributing

Agents change their config formats often. If a key was renamed, a file moved, or an example here no
longer works, a pull request is the most useful thing you can send.

## What a good PR looks like

- **One agent or one provider per PR**, so it can be reviewed quickly.
- **A source link for every changed key**: the agent's official docs page, or the source file on its
  default branch. Release notes are fine for renames.
- **Say how you checked it.** For example "ran `opencode run` with this config against provider X",
  or "copied from docs page Y, not run". Both are welcome; the README marks which is which.
- **Update the "Last checked" date** of the section you touched.
- **Placeholders, never real keys.** Use `YOUR_PROVIDER_API_KEY`, `MODEL_ID` and `https://YOUR_PROVIDER/v1`.

## Adding an agent

Add it when people actually use it with custom providers. Follow the shape of the existing sections:
config file path and format, a minimal example, env vars, gotchas, sources.

## Adding a provider preset

The provider needs a public OpenAI- or Anthropic-compatible endpoint and a docs page that states the
base URL. Link that page. Keep the pricing note short and factual (how you pay, not how good it is).
No rankings, superlatives or affiliate links. Vendors adding their own row are welcome; please say so
in the PR.

## Reporting a problem without a fix

Open an issue with the agent and version, the config you used (keys removed), and the error.
