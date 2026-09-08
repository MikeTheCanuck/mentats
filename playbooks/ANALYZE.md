# ANALYZE

This step runs on Maestro's default Claude Code agent config — no
`customEnvVars` override. That means it talks to real Anthropic, plain,
unproxied. This is deliberate: understanding a codebase or a bug well
enough to hand off a real plan is exactly the "pop a Mentat" judgment work
this whole project exists to protect, not something to route to a local
model by default.

Maestro spawns a fresh, independent agent session for each Playbook
document — ANALYZE, PLAN, and IMPLEMENT do not share conversational
memory with each other. The only thing that survives across documents in
one Auto Run job is the filesystem, specifically the
`{{AUTORUN_FOLDER}}/Working` directory. Writing your output only in chat
means the next document can never see it — write it to a real file.

## Task

- [ ] Read the target repository and identify what the current behavior is, with file/line references.
- [ ] Identify what's actually being asked for, distinguished from what was literally requested if they differ.
- [ ] Note any constraints discovered by reading the code that weren't visible from the task description alone.
- [ ] Write all three findings to `{{AUTORUN_FOLDER}}/Working/analysis.md` as a single analysis document. Create the `Working` directory first if it doesn't exist.

## Exit condition

`{{AUTORUN_FOLDER}}/Working/analysis.md` exists and covers all three
points above. Hand off to PLAN.
