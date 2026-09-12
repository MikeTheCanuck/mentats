# Testing status

Where end-to-end validation actually stands, updated as testing progresses. Read this before touching `playbooks/` or debugging Maestro further — it says exactly what's confirmed, what's fixed-but-unconfirmed, and what the next concrete action is. See `docs/decisions.md` for the *why* behind each fix; this file is just the *where are we right now*.

## Confirmed working (real evidence, not inference)

- **Local routing.** A Maestro agent with the right `customEnvVars` set genuinely routes Claude Code traffic to CCR and on to a local LM Studio model — confirmed by watching real inference traffic land in LM Studio during an IMPLEMENT run.
- **Memory stability.** The recurring LM Studio memory-pressure crash (3 hard crashes) is fixed: switched to `Qwen3-Coder-30B-A3B-Instruct-MLX-4bit` (not a vision/VLM model, so KV Cache Quantization actually works on it), context length capped at 65K. Confirmed stable under real load, watched live in Activity Monitor.
- **Checkbox task format.** Maestro's Auto Run counts tasks via `/^- \[([ x])\]/gm` — confirmed by a real run completing "8 of 8 tasks" across ANALYZE+PLAN after the format fix landed.
- **Repo-binding fix exists and is correct.** Right-click a folder in Maestro's Files panel → **"New Agent Here"** pre-fills the correct working directory and repo together. This was shipped upstream (`runmaestro/maestro#1301`) before this project's v1 was even built — we just hadn't found it. Don't use the global hamburger-menu "New Agent" for a repo-scoped agent; that path is what caused the original repo-binding bug.
- **Worktree-dispatch mechanism, confirmed by a Maestro maintainer.** Only **"Open in Maestro"** (targeting an agent that's already open) runs a document under a different agent's environment. "Create New Worktree" and "Available Worktrees" both copy the *parent* agent's `customEnvVars` — picking either of those when you want different routing will silently not do what you expect. See `runmaestro/maestro#1548`/`#1549`.
- **`customEnvVars` is editable anytime**, not creation-time-only: Edit Agent (`⌥⌘,`, right-click → Edit Agent, or `⌘K`), or `maestro-cli update-agent <id> --env KEY=value`. No need to delete/recreate an agent just to change its environment.

## Fixed, not yet confirmed end-to-end

- **Playbook context handoff.** `ANALYZE.md`/`PLAN.md` now write to `{{AUTORUN_FOLDER}}/Working/{analysis,plan}.md`; `PLAN.md`/`IMPLEMENT.md` read those files explicitly, instead of assuming shared conversational memory across documents (Maestro spawns a fresh independent session per document — confirmed via its own "Fresh Context Per: Document" setting). This fix has never been tested through a full run. The last attempt after this fix landed hit an unexplained error before reaching IMPLEMENT (see below).

## Last known blocker (unresolved, never retried)

The most recent live test hit a raw JSON error on **ANALYZE** itself:

```json
{"model": "<synthetic>", "is_api_error_message": true, "error": "unknown", ...}
```

This is Claude Code's own harness synthesizing a placeholder message when something fails at the API/transport layer — not a real model response, and not something ANALYZE's instructions caused. We never confirmed which agent ANALYZE was actually running under at the time (there was a lot of agent create/delete churn that session), and we never retried it. **This is the actual next thing to resolve** — it may be a transient API blip, or it may recur.

## Next concrete step

1. If the `qbit-prunarr` test agent doesn't currently exist or its repo-binding is in doubt, recreate it via **right-click the `qbit-prunarr` folder in Files → "New Agent Here"** (not the hamburger New Agent). Set its `customEnvVars` per `config/ccr-provider-values.md` and the table in `playbooks/IMPLEMENT.md`.
2. Run `ANALYZE.md` + `PLAN.md` together, no worktree dispatch (plain default agent, real Anthropic). Confirm no repeat of the synthetic API error. If it recurs, that's now a real, reproducible bug worth its own investigation rather than a one-off.
3. Confirm `{{AUTORUN_FOLDER}}/Working/analysis.md` and `plan.md` actually got written (check the Auto Run working folder, or the agent's transcript) — this is the first real test of the context-handoff fix.
4. Queue `IMPLEMENT.md` alone, worktree dispatch **on**, targeting the `qbit-prunarr` agent via **"Open in Maestro"** specifically (not "Create New Worktree" or "Available Worktrees").
5. Watch CCR's Logs (`ccr ui` → Logs) for a request during this run, and check `git status` in `qbit-prunarr` afterward for real file changes.

If all five steps pass clean, this is the first fully-confirmed end-to-end run, and Mentats' core mechanism is genuinely validated — at that point it's reasonable to consider pointing this at something that actually matters, per `docs/decisions.md`'s existing caution about not doing that prematurely.
