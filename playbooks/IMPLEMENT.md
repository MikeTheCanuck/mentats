# IMPLEMENT

This is the one step that routes to a local model. Set this Playbook
task's `customEnvVars` to point Claude Code at CCR's gateway instead of
Anthropic directly — see `config/ccr-provider-values.md` for how CCR itself
gets configured, and CCR's own agent-profile docs for the exact env var
names/values your CCR version expects (they're set per-profile in CCR's
dashboard, then referenced here).

CCR's default gateway address is `http://127.0.0.1:3456` — confirm this
against your installed CCR version's own docs, since the default could
change between versions. Conceptually, the `customEnvVars` block just needs
an `ANTHROPIC_BASE_URL`-style variable pointed at that address, e.g.:

```
customEnvVars:
  ANTHROPIC_BASE_URL: http://127.0.0.1:3456
```

Treat the port as relatively stable but the exact env var key name(s) as
more likely to drift — check your CCR version's agent-profile docs for the
exact key names before relying on this example.

## Task

- [ ] Execute PLAN's output exactly — no new architecture or approach decisions here; those were already made in PLAN, on the model that's actually good at making them. If IMPLEMENT gets stuck on a decision PLAN didn't already resolve, that's a signal PLAN wasn't specific enough, not a cue to improvise.
- [ ] Run whatever verification PLAN specified.
- [ ] If verification fails in a way that needs real judgment to diagnose, stop and escalate to a human rather than looping on a local model alone — v1 has no automated fallback for this.

## Exit condition

The plan's changes are made, and whatever verification PLAN specified
passes. If verification fails in a way that needs real judgment to
diagnose, escalate back to a human rather than looping on a local model
alone — v1 has no automated fallback for this.
