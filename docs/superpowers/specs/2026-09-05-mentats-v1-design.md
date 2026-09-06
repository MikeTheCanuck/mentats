# Mentats v1 — design spec

## Pitch

The problem this solves is not "save money on tokens" — it's momentum. A $20/month Anthropic subscription's 5-hour usage window turns real, sustained agentic work into stop-and-wait cycles: hit the wall, lose the thread, come back hours later to work that's gone cold. As open-weight models close the gap to "good enough" and token subsidies come off, routing the grind to local compute and reserving frontier models for genuine judgment calls stops being a curiosity and starts being how individuals do what enterprises already have to do with FinOps. See `docs/positioning.md` for the full argument — read that before touching the README, it's the actual thesis, not just backstory.

Mechanically: Mentats provisions a single-user, LM Studio-biased local-inference stack for Claude Code, orchestrated by Maestro. Local models handle mechanical "grinding" execution by default; a Maestro Playbook can deliberately let a specific step "pop a Mentat" — run on real Anthropic — when the task genuinely needs judgment.

Public, MIT-licensed, work-in-the-open project. Intended both as a working tool and as source material for a LinkedIn post series (the posts themselves live on LinkedIn, not in this repo — see `docs/decisions.md`).

## Scope (v1)

**In scope:**
- `install.sh` — provisions `claude-code-router` (CCR) and an LM Studio provider config on macOS, fully templated (no machine-specific paths or tokens baked in; derives `$HOME` etc. at install time).
- `config/ccr-provider-values.md` — the exact values to enter into CCR's own Providers → Add Provider wizard (endpoint, protocol, model names). CCR has no documented file-based or CLI config mechanism — provider setup is GUI-only, persisted to an internal SQLite DB (confirmed against CCR's own GitHub docs) — so this is a copy-paste reference for the manual step, not a file the installer writes for you.
- `playbooks/ANALYZE.md`, `playbooks/PLAN.md`, `playbooks/IMPLEMENT.md` — example Maestro Playbook documents. These are the actual mechanism: `IMPLEMENT.md` carries `customEnvVars` pointing at CCR/local; `ANALYZE.md`/`PLAN.md` are left unmodified, inheriting Maestro's default (plain Anthropic) agent config. This is "popping a Mentat" — a deliberate, Playbook-authored choice, not a command a human types.
- `docs/architecture.md` — the real rationale already worked out in prior sessions: why local-by-default, the ToS-compliance boundary (the Anthropic OAuth leg is never proxied through CCR), why Maestro is a dumb relay rather than a smart supervisor, why Maestro projects are scoped one-repo-at-a-time.
- `docs/decisions.md` — short ADR-style log of what's been decided and why, including what's explicitly deferred.
- `README.md`, `LICENSE` (MIT), `CONTRIBUTING.md`. README leads with the argument in `docs/positioning.md`, not with config instructions. For dependency setup (installing CCR itself, LM Studio, Maestro), the README points to each project's own authoritative docs rather than duplicating install steps that are someone else's moving target to maintain — Mentats documents what it adds on top, not how to install things it doesn't own.

**Explicitly out of scope for v1** (see `docs/decisions.md` for the full deferred list):
- A manual CLI wrapper (successor to the working `clauder()` shell function) — deferred as a documented fallback, to build only if the Maestro-orchestrated flow proves unreliable to keep running.
- Live/dynamic mid-task escalation, where the running agent itself decides to escalate rather than it being fixed at Playbook-authoring time.
- Any engineered usage/budget guard capping how often escalation happens. The "non-addictive" framing is intentional flavor (real Fallout Mentats are non-addictive, unlike Jet/Psycho/Buffout), not a promise of an enforced cap — the actual guardrail is "you authored the Playbook, you already know how often it escalates."
- Automating Maestro's own installation (proprietary Electron app, installed manually via its own GitHub Releases page).
- Any platform other than macOS (Homebrew, zsh, LM Studio's Mac app) — explicitly documented as a v1 limitation, with `CONTRIBUTING.md` inviting Linux/Windows users to contribute their own setup.

## Architecture

Two Claude Code invocations, spawned independently by Maestro per Playbook step — never one process "aware of" or delegating to the other mid-conversation (Maestro is a dumb relay, not a smart supervisor):

- **ANALYZE / PLAN steps:** inherit Maestro's default agent config. Per the ToS-compliance decision, this is always the plain, unproxied `claude` CLI talking directly to Anthropic — the OAuth-authenticated subscription leg never passes through CCR.
- **IMPLEMENT step:** carries a Playbook-level `customEnvVars` override pointing at CCR's gateway (`http://127.0.0.1:3456` by default), which routes to whichever local LM Studio model is configured. This is the only step that ever touches local inference in v1.

`install.sh`'s job is narrow: get CCR and LM Studio's provider config set up correctly so that override works. It does not touch Maestro's own configuration, and does not change what a plain, interactively-typed `claude` command does outside of Maestro entirely — that stays exactly as it is today (real Anthropic), matching the existing verified-working `clauder()`-based setup this project formalizes.

## Data flow / install script behavior

1. Check prerequisites: macOS version, npm present.
2. Install `claude-code-router` globally via npm if not already present.
3. Detect the local LM Studio server (`http://localhost:1234/v1` by default) and confirm it responds — this is what the manual CCR provider step will point at.
4. Print the path to `config/ccr-provider-values.md` as a pointer for the user to follow, rather than reproducing its values inline — install.sh cannot write this config itself (CCR has no file-based or CLI config mechanism, only a GUI persisting to an internal SQLite DB), and keeping the values in one place avoids the file and the script's output drifting out of sync.
5. Print next steps: complete the CCR GUI step above, how to install Maestro manually, where the example Playbooks live, and a pointer to `docs/architecture.md` for the "why."

Idempotent: safe to re-run; re-running just re-writes the generated config rather than erroring if it already exists.

## Error handling

- LM Studio not running / unreachable at the expected port: install.sh reports this clearly and exits without writing a broken config, rather than generating a provider config pointing at a dead endpoint.
- CCR already installed at a different version: warn, don't force-reinstall.
- npm missing: fail fast with a clear message; v1 doesn't attempt to install Node.js itself. (Not Homebrew — install.sh never invokes `brew`; npm is the actual dependency, and on the reference machine it's managed via fnm, not Homebrew.)

## Testing

- `install.sh` is a shell script gluing together existing tools (npm, curl checks) rather than novel logic — testing is primarily manual verification on a real machine (this is explicitly a single-user, personally-dogfooded project), not a unit-test suite.
- The Playbook templates are documentation-as-config; "testing" them means actually running a Playbook against a real low-stakes repo once Maestro is installed, per the original handoff doc's own checklist (not yet done as of this spec).

## Related prior work

The real, working version of everything described here already exists on Mike's machine and is documented in the `-Users-mike-code` memory bucket (`project_local_llm_setup.md`, `project_agentic_helper_repo.md`) — this repo formalizes and publishes it, it does not design it from scratch.
