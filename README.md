# Mentats

Not everyone can afford frontier models for all their work — and as token
subsidies come off while open-weight models close the gap to "good enough,"
routing the grind to local compute and reserving frontier models for real
judgment calls stops being a curiosity and starts being how individuals do
what enterprises already have to do with token-spend efficiency.

Concretely: a $20/month Anthropic subscription's 5-hour usage window turns
sustained agentic work into stop-and-wait cycles. Hit the wall, lose the
thread, come back hours later to work that's gone cold. Mentats exists to
let local models (via LM Studio) handle the mechanical grind by default,
while a Maestro Playbook step deliberately "pops a Mentat" — escalates to
real Anthropic — only when a task genuinely needs judgment, not on a timer
and not because you ran out of tokens mid-thought.

Full argument: [docs/positioning.md](docs/positioning.md).
How it actually works under the hood: [docs/architecture.md](docs/architecture.md).
What's decided, deferred, and rejected, and why: [docs/decisions.md](docs/decisions.md).

## What this is

- `install.sh` — installs [claude-code-router](https://github.com/musistudio/claude-code-router)
  (CCR) and confirms a local [LM Studio](https://lmstudio.ai) server is
  reachable. It does not configure CCR's provider for you — CCR has no
  file-based config, only a GUI — see
  [config/ccr-provider-values.md](config/ccr-provider-values.md) for the
  exact values to enter.
- `playbooks/` — example [Maestro](https://github.com/RunMaestro/Maestro)
  Playbook documents (ANALYZE, PLAN, IMPLEMENT) showing the actual
  escalation mechanism: IMPLEMENT routes to local via a `customEnvVars`
  override, ANALYZE and PLAN don't.

## What this isn't (yet)

No manual CLI wrapper, no live mid-task escalation decided by a running
agent, no built-in usage cap. See
[docs/decisions.md](docs/decisions.md#deferred-not-rejected) for what's
deferred versus deliberately rejected, and why.

## Setup

1. Install and configure [LM Studio](https://lmstudio.ai) and load a model —
   see LM Studio's own docs for this; Mentats doesn't duplicate them. Then
   start LM Studio's local server (Developer tab → Server → Start) — this is
   a separate step from loading a model, and `install.sh` requires the
   server to be running and reachable.
2. Run `./install.sh`. It checks for Homebrew and macOS, installs CCR if
   needed, and confirms LM Studio's server is reachable.
3. Follow [config/ccr-provider-values.md](config/ccr-provider-values.md) to
   finish CCR's provider setup in its own GUI.
4. Install [Maestro](https://github.com/RunMaestro/Maestro) from its own
   GitHub Releases page, and use the templates in `playbooks/` as a
   starting point for your own Maestro project.

## Platform

macOS only for v1. See [CONTRIBUTING.md](CONTRIBUTING.md) if you want to
help extend this to Linux or Windows.

## License

[MIT](LICENSE)
