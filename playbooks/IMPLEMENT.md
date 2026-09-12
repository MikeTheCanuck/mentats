# IMPLEMENT

This is the one step that routes to a local model. `customEnvVars` is not
something this document sets itself — a Playbook document cannot set
environment variables at all (Maestro renders frontmatter for you to read,
it never interprets it). The mechanism lives one level up, on a Maestro
Agent:

1. Create a separate Agent (e.g. `mentats-local`) with `customEnvVars` set
   to point Claude Code at CCR's gateway instead of Anthropic directly —
   see `config/ccr-provider-values.md` for how CCR itself gets configured,
   and CCR's own agent-profile docs for the exact env var names/values your
   CCR version expects.
2. When queuing this document in Auto Run, dispatch it to that agent via
   **"Open in Maestro"** specifically — not "Create New Worktree" or
   "Available Worktrees". Those two copy the *parent* agent's environment
   variables rather than letting you pick a different one; only "Open in
   Maestro" (targeting an agent that's already open) actually runs under
   the target agent's own environment.

CCR's default gateway address is `http://127.0.0.1:3456` — confirm this
against your installed CCR version's own docs, since the default could
change between versions. Conceptually, the agent's environment variables
just need an `ANTHROPIC_BASE_URL`-style variable pointed at that address,
e.g.:

```
ANTHROPIC_BASE_URL=http://127.0.0.1:3456
```

Treat the port as relatively stable but the exact env var key name(s) as
more likely to drift — check your CCR version's agent-profile docs for the
exact key names before relying on this example. `customEnvVars` can be
edited on an existing agent at any time (Edit Agent, or `maestro-cli
update-agent <agent-id> --env KEY=value`) — you don't need to delete and
recreate an agent just to change its environment variables.

This step also runs in its own fresh session with no memory of ANALYZE or
PLAN's conversations. `{{AUTORUN_FOLDER}}/Working/plan.md`, written by
PLAN, is the only real source of what to do — read it before doing
anything else.

## Task

- [ ] Read `{{AUTORUN_FOLDER}}/Working/plan.md`. If it doesn't exist, stop and report this — it means PLAN never ran or never wrote its file; do not guess at what the plan might have been.
- [ ] Execute that plan's contents exactly — no new architecture or approach decisions here; those were already made in PLAN, on the model that's actually good at making them. If IMPLEMENT gets stuck on a decision the plan didn't already resolve, that's a signal PLAN wasn't specific enough, not a cue to improvise.
- [ ] Run whatever verification the plan specified.
- [ ] If verification fails in a way that needs real judgment to diagnose, stop and escalate to a human rather than looping on a local model alone — v1 has no automated fallback for this.

## Exit condition

The plan's changes are made, and whatever verification PLAN specified
passes. If verification fails in a way that needs real judgment to
diagnose, escalate back to a human rather than looping on a local model
alone — v1 has no automated fallback for this.
