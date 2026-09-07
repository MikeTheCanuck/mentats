# PLAN

Like ANALYZE, this step has no `customEnvVars` override — it runs on
Maestro's default agent config, talking to real Anthropic. Planning is
where a wrong call is expensive to unwind later; this is squarely
judgment-heavy work.

## Task

- [ ] Read ANALYZE's output.
- [ ] Produce a concrete implementation plan: which files change, and in what order.
- [ ] Specify how each change will be verified.
- [ ] Make the plan specific enough that IMPLEMENT (running on a local model) can execute it without needing to make further judgment calls about approach — only about mechanical correctness.

## Exit condition

A written plan exists, is specific enough to execute without re-deciding
approach, and has been reviewed (by you, reading it, before handing off —
this project deliberately has no automated plan-reviewer step in v1).
Hand off to IMPLEMENT.
