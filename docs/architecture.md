# Architecture

## The two-invocation model

Mentats never has one Claude Code process "aware of" or delegating to
another mid-conversation. Maestro spawns two entirely separate, independent
`claude` invocations per Playbook run:

- **ANALYZE / PLAN steps** inherit Maestro's default agent config — the
  plain, unproxied `claude` CLI talking directly to Anthropic. No override,
  no local routing.
- **IMPLEMENT step** carries a Playbook-level `customEnvVars` override
  pointing at CCR's gateway (`http://127.0.0.1:3456` by default), which
  routes to whichever local LM Studio model is configured. This is the only
  step that ever touches local inference.

There's no smart supervisor deciding at runtime which model a given moment
needs — the judgment call is made once, when the Playbook is written, not
live during execution. See `docs/decisions.md` for why that's a deliberate
v1 scope choice, not an oversight.

## Why the Anthropic OAuth leg is never proxied

Routing Claude.ai/Pro/Max OAuth subscription tokens through third-party
tools outside the official client sits in a gray zone under Anthropic's
terms — not clearly sanctioned, not clearly forbidden, and not a risk worth
taking on. Mentats deliberately stays out of that gray zone rather than
relying on it: CCR is used here purely to route to local LM Studio models —
the ANALYZE/PLAN steps'
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
