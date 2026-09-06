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
