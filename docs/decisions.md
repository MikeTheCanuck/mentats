# Decisions

Short log of what's been decided for Mentats and why. Update this as decisions get made or revisited — it's meant to be a living record, not a one-time writeup.

## Locked

- **Name: Mentats.** Fallout's cognitive-boost chem — the one that's canonically non-addictive, unlike Jet/Psycho/Buffout. Boosts Intelligence/Perception specifically, not damage or speed, which maps onto "escalate to real judgment when needed" better than a generic power-up or a roadie's-name metaphor (both explored and rejected — see git history / commit messages for the naming search if curious).
- **License: MIT.** Maximally permissive; the whole point is other people harvesting scripts/config, not policing derivative use.
- **Local is the default stance, escalation is the deliberate exception.** Technically this didn't require inverting any mechanism — it's a framing choice. See Architecture below.
- **Escalation is fixed at Playbook-authoring time, not decided live by the running agent.** Maestro owns per-task routing entirely; there is no manual command a human runs to switch models. This matches how the actual work happens day to day — manually overriding the model choice is rare enough that building for it first would be solving the wrong problem.
- **The Anthropic OAuth leg is never proxied.** CCR is used purely for routing to local LM Studio models. Plain, unproxied `claude` always talks to Anthropic directly — this is a deliberate ToS-compliance boundary, reconfirmed multiple times during design, including after almost building it wrong once (see Deferred/rejected below).
- **macOS only for v1.** Matches the actual environment (Homebrew, zsh, LM Studio's Mac app). Not a permanent restriction — `CONTRIBUTING.md` explicitly invites Linux/Windows users to contribute their own setup, rather than building/maintaining platforms that can't be tested firsthand.
- **`install.sh` is fully templated.** No machine-specific paths, usernames, or token file locations get committed — the script derives what it needs at install time. This is a hygiene requirement, not a nice-to-have: an earlier real version of this setup had a literal home-directory path and an identity-token-file path baked into a shell function.
- **LinkedIn post series content lives outside this repo.** The repo stays focused on the tool; posts are drafted and published on LinkedIn directly and just link back here.

## Corrected during planning

- **`install.sh` cannot write CCR's provider config directly.** The original spec assumed a file-based config CCR would read; checking CCR's own docs during plan-writing confirmed provider setup is GUI-only (Providers → Add Provider), persisted to an internal SQLite DB, with no documented file or CLI config-import path. `config/ccr-provider-values.md` (originally planned as a JSON file the installer would write) is instead a copy-paste reference for that manual GUI step. install.sh's job stays limited to installing CCR itself and confirming LM Studio is reachable.

## Deferred, not rejected

- **A manual CLI wrapper** (successor to the real, working `clauder()` shell function this project formalizes) that lets a human manually invoke a differently-routed session outside of Maestro entirely. **Explicitly kept as a fallback option to build later** if the Maestro-orchestrated Playbook flow turns out to be unreliable to keep running day to day. Don't forget this exists as an option — it's cheap to add later since the underlying CCR routing config doesn't change, only how it gets invoked.
- **Live, mid-task escalation** — the running agent deciding for itself, in the moment, that a sub-task needs to "pop a Mentat," rather than that being fixed when the Playbook was written. This is the more literal reading of "pop a Mentat anytime it likes," but it's a real new mechanism (an actual callable escalation path, not just config) rather than something buildable from what already exists. If this gets built, **Logan's Loophole** — the real Fallout perk that removes chem-addiction risk entirely — is a strong candidate name for it.
- **An engineered usage/budget guard** limiting how often escalation can happen. The "non-addictive" framing is intentional flavor, not a feature promise — the actual guardrail is that whoever authors a Playbook already controls and knows its escalation frequency.
- **Automating Maestro's own installation.** It's a proprietary Electron app distributed via its own GitHub Releases page; a script has no safe, sanctioned way to automate that, and shouldn't try.

## Rejected

- **bborbe/claude-code-router** (OAuth passthrough) — sits in the Anthropic ToS gray zone around routing subscription tokens through third-party tools. Ruled out in favor of routing only to local models, never touching the Anthropic leg.
- **Setting CCR's routing env vars on Maestro's global Claude Code provider config.** Would route every Maestro-spawned session, including planning, through CCR to local-only models — defeats the entire point. The correct scope is per-Playbook-task `customEnvVars`, not the agent's global config. (This was nearly built wrong once during design — worth remembering why.)
- **A full multi-agent "Council" review architecture** (architect/PM/QA/skeptic personas reviewing every plan) built upfront. At most one review/skeptic checkpoint between plan and execution, added only if a real instance of bad output getting wrongly accepted is actually observed.
