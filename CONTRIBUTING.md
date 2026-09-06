# Contributing to Mentats

Mentats v1 is macOS-only. That's a scope decision, not a design constraint —
the install script assumes Homebrew and Bash, and the whole stack (LM Studio's
desktop app, in particular) was only built and tested on macOS.

Linux and Windows support is genuinely welcome as a contribution, not just
tolerated. If you run this on either and want to send a PR:

- Keep `install.sh`'s macOS-specific logic behind a clear OS check rather than
  rewriting it in place — the goal is one script that branches, not two
  scripts to keep in sync.
- Say what you tested it against (distro/version, or Windows build) in the PR
  description.
- If LM Studio or CCR themselves behave differently on your platform, link to
  their own docs/issues rather than re-explaining their behavior here.

For anything else — bugs, doc fixes, Playbook template improvements — open an
issue or PR as normal. This is a solo hobby project published in the open, so
response times may be slow, not because contributions aren't wanted.
