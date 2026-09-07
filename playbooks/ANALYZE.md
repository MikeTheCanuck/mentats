# ANALYZE

This step runs on Maestro's default Claude Code agent config — no
`customEnvVars` override. That means it talks to real Anthropic, plain,
unproxied. This is deliberate: understanding a codebase or a bug well
enough to hand off a real plan is exactly the "pop a Mentat" judgment work
this whole project exists to protect, not something to route to a local
model by default.

## Task

- [ ] Read the target repository and identify what the current behavior is, with file/line references.
- [ ] Identify what's actually being asked for, distinguished from what was literally requested if they differ.
- [ ] Note any constraints discovered by reading the code that weren't visible from the task description alone.
- [ ] Write up all three findings as a single analysis document.

## Exit condition

A written analysis document exists and covers all three points above. Hand
off to PLAN.
