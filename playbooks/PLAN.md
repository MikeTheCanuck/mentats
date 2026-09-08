# PLAN

Like ANALYZE, this step has no `customEnvVars` override — it runs on
Maestro's default agent config, talking to real Anthropic. Planning is
where a wrong call is expensive to unwind later; this is squarely
judgment-heavy work.

Like ANALYZE, this step runs in its own fresh session with no memory of
the previous one — the only thing carried forward is whatever was written
to `{{AUTORUN_FOLDER}}/Working`. Read ANALYZE's actual file; don't assume
you already know what it found.

## Task

- [ ] Read `{{AUTORUN_FOLDER}}/Working/analysis.md`.
- [ ] Produce a concrete implementation plan: which files change, and in what order.
- [ ] Specify how each change will be verified.
- [ ] Make the plan specific enough that IMPLEMENT (running on a local model) can execute it without needing to make further judgment calls about approach — only about mechanical correctness.
- [ ] Write the plan to `{{AUTORUN_FOLDER}}/Working/plan.md`.

## Exit condition

`{{AUTORUN_FOLDER}}/Working/plan.md` exists, is specific enough to
execute without re-deciding approach, and has been reviewed (by you,
reading it, before handing off — this project deliberately has no
automated plan-reviewer step in v1). Hand off to IMPLEMENT.
