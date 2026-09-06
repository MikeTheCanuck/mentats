# Mentats v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish Mentats v1 — a documented, MIT-licensed installer and Maestro Playbook template set that provisions a local-model-by-default, Anthropic-on-escalation Claude Code setup on macOS.

**Architecture:** `install.sh` installs `claude-code-router` (CCR) and verifies LM Studio is reachable, then hands the user a copy-paste reference for CCR's own GUI provider setup (CCR has no file-based config — confirmed against its own docs). Three Maestro Playbook template docs encode the actual escalation mechanism: `IMPLEMENT.md` carries a `customEnvVars` override routing to CCR/local, `ANALYZE.md`/`PLAN.md` are left unmodified, inheriting Maestro's default (plain Anthropic) agent. README leads with the project's actual thesis (`docs/positioning.md`), not with setup mechanics.

**Tech Stack:** Bash (install.sh), Markdown (all docs/config/playbooks), no runtime dependencies beyond what the script shells out to (`brew`, `npm`, `curl`).

**Spec:** `docs/superpowers/specs/2026-09-05-mentats-v1-design.md` (read alongside `docs/decisions.md` and `docs/positioning.md` in the same repo — both already committed, do not recreate them).

## Global Constraints

- macOS only for v1 (assumes Homebrew + Bash are available; no Linux/Windows branches).
- `install.sh` must contain zero machine-specific paths, usernames, or tokens — everything is derived at runtime (`$HOME`, `command -v`, etc.).
- No manual CLI wrapper, no live/dynamic escalation, no usage/budget guard, no Maestro-install automation — all explicitly out of scope per the spec.
- CCR provider config is GUI-only (SQLite-backed) — nothing in this repo writes CCR config directly; `config/ccr-provider-values.md` is a copy-paste reference only.
- README must point to CCR's, LM Studio's, and Maestro's own docs for their install steps rather than duplicating them.
- MIT license.
- Testing is manual verification (this is a dogfooded single-user tool, not a library) — no unit-test framework gets introduced. Each task's test step is a real, runnable shell check.

---

## File Structure

```
mentats/
  LICENSE
  CONTRIBUTING.md
  install.sh
  config/
    ccr-provider-values.md
  playbooks/
    ANALYZE.md
    PLAN.md
    IMPLEMENT.md
  docs/
    architecture.md
    positioning.md      (already exists — do not modify)
    decisions.md         (already exists — append only if a task needs to log a new decision)
    superpowers/
      specs/2026-09-05-mentats-v1-design.md   (already exists)
      plans/2026-09-05-mentats-v1-implementation.md  (this file)
  README.md
```

---

### Task 1: LICENSE and CONTRIBUTING

**Files:**
- Create: `LICENSE`
- Create: `CONTRIBUTING.md`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing other tasks read programmatically — README will link to both by exact filename (`LICENSE`, `CONTRIBUTING.md`), so keep those exact names.

- [ ] **Step 1: Write the MIT license**

Create `LICENSE`:

```
MIT License

Copyright (c) 2026 Mike

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 2: Write CONTRIBUTING.md**

Create `CONTRIBUTING.md`:

```markdown
# Contributing to Mentats

Mentats v1 is macOS-only. That's a scope decision, not a design constraint —
the install script assumes Homebrew and Bash, and the whole stack (LM Studio's
desktop app, in particular) was only built and tested on macOS.

Linux and Windows support is genuinely welcome as a contribution, not just
tolerated. If you run this on either and want to send a PR:

- Keep `install.sh`'s macOS-specific logic behind a clear OS check rather than
  rewriting it in place — the goal is one script that branches, not two
  scripts to keep in sync.
- Say what you tested it against (distro/version, or Windows build) in the PR
  description.
- If LM Studio or CCR themselves behave differently on your platform, link to
  their own docs/issues rather than re-explaining their behavior here.

For anything else — bugs, doc fixes, Playbook template improvements — open an
issue or PR as normal. This is a solo hobby project published in the open, so
response times may be slow, not because contributions aren't wanted.
```

- [ ] **Step 3: Verify both files are valid**

Run: `test -s LICENSE && test -s CONTRIBUTING.md && echo OK`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add LICENSE CONTRIBUTING.md
git commit -m "Add MIT license and contributing guide"
```

---

### Task 2: CCR provider values reference

**Files:**
- Create: `config/ccr-provider-values.md`

**Interfaces:**
- Consumes: nothing.
- Produces: a file path (`config/ccr-provider-values.md`) that Task 4 (`install.sh`) prints a pointer to by exact relative path, and that Task 6 (`README.md`) links to by the same exact path. Keep the filename and path exact.

- [ ] **Step 1: Write the reference doc**

Create `config/ccr-provider-values.md`:

```markdown
# CCR provider setup — manual reference

CCR (claude-code-router) has no file-based or CLI config mechanism for
providers — this is confirmed against its own documentation. Provider setup
is GUI-only, through CCR's dashboard, and persists to an internal database.
`install.sh` cannot do this step for you; these are the exact values to enter.

1. Open CCR's dashboard (`ccr ui`, or the URL it prints on startup).
2. Go to **Providers → Add Provider**.
3. Fill in:
   - **Name:** `LM Studio` (or anything memorable — this is just a label)
   - **Endpoint:** `http://localhost:1234/v1` (LM Studio's default local server
     address — confirm yours matches under LM Studio's Developer tab → Server
     Settings if you've changed the port)
   - **Protocol:** OpenAI Chat (LM Studio's local server speaks the
     OpenAI-compatible API)
   - **API Key:** any non-empty placeholder (e.g. `local`) — CCR's form
     requires a non-empty string even though LM Studio doesn't check it by
     default
   - **Models:** whichever model IDs are currently loaded in LM Studio. Run
     `curl -s http://localhost:1234/v1/models` with LM Studio's server running
     to see the exact IDs — they don't always match the model's download name.
4. Click **Check Connection**, then **Save**.
5. Under **Agent Config → Add Profile**, create a Claude Code profile using
   this provider, and note its name — you'll reference it in the Playbook
   templates under `playbooks/`.

See CCR's own docs for anything beyond this (provider.md, agent-profile.md in
musistudio/claude-code-router's repo) — this file only covers the values
specific to pairing it with a local LM Studio server.
```

- [ ] **Step 2: Verify the file renders as valid markdown with no broken internal references**

Run: `grep -c "^#" config/ccr-provider-values.md`
Expected: a number >= 1 (confirms at least one heading exists, i.e. the file isn't empty/corrupted)

- [ ] **Step 3: Commit**

```bash
git add config/ccr-provider-values.md
git commit -m "Add CCR provider setup reference"
```

---

### Task 3: Architecture doc

**Files:**
- Create: `docs/architecture.md`

**Interfaces:**
- Consumes: `docs/decisions.md` and `docs/positioning.md` (read for accuracy, do not modify).
- Produces: a file path (`docs/architecture.md`) that Task 6 (`README.md`) links to by this exact path.

- [ ] **Step 1: Write the architecture doc**

Create `docs/architecture.md`:

```markdown
# Architecture

## The two-invocation model

Mentats never has one Claude Code process "aware of" or delegating to
another mid-conversation. Maestro spawns two entirely separate, independent
`claude` invocations per Playbook run:

- **ANALYZE / PLAN steps** inherit Maestro's default agent config — the
  plain, unproxied `claude` CLI talking directly to Anthropic. No override,
  no local routing.
- **IMPLEMENT step** carries a Playbook-level `customEnvVars` override
  pointing at CCR's gateway, which routes to whichever local LM Studio model
  is configured. This is the only step that ever touches local inference.

There's no smart supervisor deciding at runtime which model a given moment
needs — the judgment call is made once, when the Playbook is written, not
live during execution. See `docs/decisions.md` for why that's a deliberate
v1 scope choice, not an oversight.

## Why the Anthropic OAuth leg is never proxied

Anthropic's terms prohibit routing Claude.ai/Pro/Max OAuth subscription
tokens through third-party tools outside the official client. CCR is used
here purely to route to local LM Studio models — the ANALYZE/PLAN steps'
plain `claude` invocation never passes through CCR's gateway at all. This
boundary is load-bearing: it's the difference between "using CCR to reach
local models" (fine) and "using CCR to relay your Anthropic subscription"
(the gray-area behavior this project deliberately avoids).

## Why Maestro is a dumb relay, not a smart supervisor

It would be simpler to build a single process that decides per-task whether
to call Anthropic or a local model. Mentats doesn't do this, on purpose:
Maestro's job is to spawn separate, independent CLI invocations and stitch
them together structurally through Playbook documents and exit conditions —
it has no judgment of its own catching bad plans or bad output. Whatever
judgment exists lives entirely inside whichever Claude invocation is running
at that moment. This keeps the trust boundary simple: you always know
exactly which model produced a given piece of output, because it's
determined by which Playbook step ran, not by an opaque routing decision
made mid-task.

## Why one repo at a time

Maestro projects here are scoped to a single repository, not a parent
directory covering multiple projects. Loose cross-project visibility is
fine when a human is watching interactively in real time — that safety
property disappears the moment you add unattended operation, especially
paired with any permission bypass. Directory scope is the load-bearing
safety boundary once a Playbook runs without you watching every step.
```

- [ ] **Step 2: Verify all four required topics are present**

Run: `grep -c "^## " docs/architecture.md`
Expected: `4`

- [ ] **Step 3: Commit**

```bash
git add docs/architecture.md
git commit -m "Add architecture doc"
```

---

### Task 4: install.sh

**Files:**
- Create: `install.sh`
- Modify: none

**Interfaces:**
- Consumes: `config/ccr-provider-values.md` (prints its path, does not parse it).
- Produces: exit code 0 on success, non-zero with a clear stderr message on any prerequisite failure. No files written outside of what `npm install -g` itself does — this script has no repo-local side effects to track.

- [ ] **Step 1: Write install.sh with prerequisite checks**

Create `install.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

LM_STUDIO_URL="${MENTATS_LM_STUDIO_URL:-http://localhost:1234/v1}"

fail() {
  echo "Error: $1" >&2
  exit 1
}

echo "== Mentats installer =="
echo

echo "Checking prerequisites..."
if ! command -v brew >/dev/null 2>&1; then
  fail "Homebrew is required but not found. Install it from https://brew.sh, then re-run this script."
fi

if [[ "$(uname)" != "Darwin" ]]; then
  fail "Mentats v1 is macOS-only. See CONTRIBUTING.md if you want to help add support for your platform."
fi

echo "  Homebrew: found"
echo "  macOS: confirmed"
echo
```

- [ ] **Step 2: Verify the prerequisite-failure path works**

Run: `PATH=/usr/bin:/bin bash install.sh; echo "exit code: $?"`
Expected: prints `Error: Homebrew is required...` to stderr and `exit code: 1` (Homebrew won't be on this stripped PATH on almost any real macOS machine, since `brew` lives under `/opt/homebrew/bin` or `/usr/local/bin`)

- [ ] **Step 3: Add CCR installation (idempotent)**

Append to `install.sh` (after the prerequisite checks block, before the final blank line):

```bash
echo "Checking claude-code-router..."
if command -v ccr >/dev/null 2>&1; then
  echo "  claude-code-router: already installed ($(ccr --version 2>/dev/null || echo 'version unknown'))"
else
  echo "  claude-code-router: installing via npm..."
  if ! command -v npm >/dev/null 2>&1; then
    fail "npm is required to install claude-code-router but was not found. Install Node.js (e.g. 'brew install node' or via fnm/nvm), then re-run this script."
  fi
  npm install -g @musistudio/claude-code-router
  echo "  claude-code-router: installed"
fi
echo
```

- [ ] **Step 4: Verify the CCR-already-installed path is idempotent**

Run: `bash install.sh` twice in a row on a machine that already has `ccr` on PATH (or simulate with a stub: `mkdir -p /tmp/mentats-test-bin && printf '#!/bin/sh\necho "ccr stub 1.0"\n' > /tmp/mentats-test-bin/ccr && chmod +x /tmp/mentats-test-bin/ccr && PATH="/tmp/mentats-test-bin:$PATH" bash install.sh`)
Expected: second run (or the stubbed run) prints `claude-code-router: already installed` and does NOT attempt an `npm install`

- [ ] **Step 5: Add LM Studio detection and final instructions**

Append to `install.sh`:

```bash
echo "Checking for a local LM Studio server at $LM_STUDIO_URL..."
if curl -s --max-time 3 "$LM_STUDIO_URL/models" >/dev/null 2>&1; then
  echo "  LM Studio: reachable"
else
  fail "No LM Studio server responding at $LM_STUDIO_URL. Start LM Studio's local server (Developer tab -> Server -> Start) and re-run this script, or set MENTATS_LM_STUDIO_URL if it's running on a different port."
fi
echo

echo "== Next steps =="
echo "1. Configure CCR's provider for LM Studio manually — CCR has no file-based"
echo "   config, so this is a GUI step. See: config/ccr-provider-values.md"
echo "2. Install Maestro from its own GitHub Releases page (not automated by"
echo "   this script — it's a proprietary desktop app)."
echo "3. See playbooks/ for example Maestro Playbook templates, and"
echo "   docs/architecture.md for why they're structured this way."
```

- [ ] **Step 6: Verify the LM-Studio-unreachable path works**

Run: `MENTATS_LM_STUDIO_URL=http://localhost:1 bash install.sh; echo "exit code: $?"`
Expected: prints `Error: No LM Studio server responding at http://localhost:1...` to stderr and `exit code: 1` (port 1 will refuse the connection immediately on any machine)

- [ ] **Step 7: Verify the full happy path (only if LM Studio is actually running locally)**

Run: `bash install.sh; echo "exit code: $?"`
Expected: if LM Studio's local server is running, prints through to `== Next steps ==` and `exit code: 0`. If LM Studio isn't running right now, this step is expected to fail at the LM Studio check — that's correct behavior, not a bug; re-run once LM Studio's server is started to confirm the happy path for real.

- [ ] **Step 8: Make the script executable and commit**

```bash
chmod +x install.sh
git add install.sh
git commit -m "Add install.sh"
```

---

### Task 5: Maestro Playbook templates

**Files:**
- Create: `playbooks/ANALYZE.md`
- Create: `playbooks/PLAN.md`
- Create: `playbooks/IMPLEMENT.md`

**Interfaces:**
- Consumes: nothing (these are standalone example documents, not executed by anything in this repo).
- Produces: three file paths (`playbooks/ANALYZE.md`, `playbooks/PLAN.md`, `playbooks/IMPLEMENT.md`) that Task 6 (`README.md`) links to by these exact paths.

- [ ] **Step 1: Write ANALYZE.md**

Create `playbooks/ANALYZE.md`:

```markdown
# ANALYZE

This step runs on Maestro's default Claude Code agent config — no
`customEnvVars` override. That means it talks to real Anthropic, plain,
unproxied. This is deliberate: understanding a codebase or a bug well
enough to hand off a real plan is exactly the "pop a Mentat" judgment work
this whole project exists to protect, not something to route to a local
model by default.

## Task

Read the target repository and produce a written understanding of:
- What the current behavior is, and where it lives (file/line references).
- What's actually being asked for, distinguished from what was literally
  requested if they differ.
- Any constraints discovered by reading the code that weren't visible from
  the task description alone.

## Exit condition

A written analysis document exists and covers all three points above. Hand
off to PLAN.
```

- [ ] **Step 2: Write PLAN.md**

Create `playbooks/PLAN.md`:

```markdown
# PLAN

Like ANALYZE, this step has no `customEnvVars` override — it runs on
Maestro's default agent config, talking to real Anthropic. Planning is
where a wrong call is expensive to unwind later; this is squarely
judgment-heavy work.

## Task

Given ANALYZE's output, produce a concrete implementation plan: which
files change, in what order, and how each change will be verified. The
plan should be specific enough that IMPLEMENT (running on a local model)
can execute it without needing to make further judgment calls about
approach — only about mechanical correctness.

## Exit condition

A written plan exists, is specific enough to execute without re-deciding
approach, and has been reviewed (by you, reading it, before handing off —
this project deliberately has no automated plan-reviewer step in v1).
Hand off to IMPLEMENT.
```

- [ ] **Step 3: Write IMPLEMENT.md**

Create `playbooks/IMPLEMENT.md`:

```markdown
# IMPLEMENT

This is the one step that routes to a local model. Set this Playbook
task's `customEnvVars` to point Claude Code at CCR's gateway instead of
Anthropic directly — see `config/ccr-provider-values.md` for how CCR itself
gets configured, and CCR's own agent-profile docs for the exact env var
names/values your CCR version expects (they're set per-profile in CCR's
dashboard, then referenced here).

## Task

Execute PLAN's output exactly. This step should not be making architecture
or approach decisions — those were already made in PLAN, on the model
that's actually good at making them. If IMPLEMENT gets stuck on a decision
PLAN didn't already resolve, that's a signal PLAN wasn't specific enough,
not a cue to improvise here.

## Exit condition

The plan's changes are made, and whatever verification PLAN specified
passes. If verification fails in a way that needs real judgment to
diagnose, escalate back to a human rather than looping on a local model
alone — v1 has no automated fallback for this.
```

- [ ] **Step 4: Verify all three files reference the mechanism consistently**

Run: `grep -l "customEnvVars" playbooks/*.md`
Expected: exactly `playbooks/IMPLEMENT.md` (confirms only IMPLEMENT claims the override, matching the architecture doc)

- [ ] **Step 5: Commit**

```bash
git add playbooks/
git commit -m "Add Maestro Playbook templates"
```

---

### Task 6: README

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumes: `docs/positioning.md`, `docs/architecture.md`, `docs/decisions.md`, `config/ccr-provider-values.md`, `playbooks/*.md`, `install.sh`, `LICENSE`, `CONTRIBUTING.md` (links to all of these by their exact existing paths — do not invent different filenames).
- Produces: nothing further downstream reads.

- [ ] **Step 1: Write README.md**

Create `README.md`:

```markdown
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
   see LM Studio's own docs for this; Mentats doesn't duplicate them.
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
```

- [ ] **Step 2: Verify every linked file actually exists**

Run:
```bash
for f in docs/positioning.md docs/architecture.md docs/decisions.md config/ccr-provider-values.md playbooks/ANALYZE.md playbooks/PLAN.md playbooks/IMPLEMENT.md install.sh LICENSE CONTRIBUTING.md; do
  test -f "$f" && echo "OK: $f" || echo "MISSING: $f"
done
```
Expected: every line prints `OK: <path>`, no `MISSING` lines

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "Add README"
```

---

## Final manual verification (not a subagent task — needs Mike's real machine)

This step touches global machine state (installs CCR via npm if not already
present) and requires LM Studio actually running locally — run it yourself
rather than dispatching it:

```bash
cd ~/code/mentats
./install.sh
```

Confirm it reaches `== Next steps ==` with exit code 0 on a machine where LM
Studio's server is already running, and confirm the two failure paths
(Homebrew missing, LM Studio unreachable) still behave as tested in Task 4
if you want to double check on the real machine rather than just the stubbed
tests.
