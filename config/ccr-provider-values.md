# CCR provider setup — manual reference

CCR (claude-code-router) has no file-based or CLI config mechanism for
providers — this is confirmed against its own documentation. Provider setup
is GUI-only, through CCR's dashboard, and persists to an internal database.
`install.sh` cannot do this step for you; these are the exact values to enter.

1. Open CCR's dashboard (`ccr ui`, or the URL it prints on startup).
2. Go to **Providers → Add Provider**.
3. Fill in:
   - **Name:** `LM Studio` (or anything memorable — this is just a label)
   - **Endpoint:** `http://localhost:1234/v1` (LM Studio's default local server
     address — confirm yours matches under LM Studio's Developer tab → Server
     Settings if you've changed the port)
   - **Protocol:** OpenAI Chat (LM Studio's local server speaks the
     OpenAI-compatible API)
   - **API Key:** any non-empty placeholder (e.g. `local`) — CCR's form
     requires a non-empty string even though LM Studio doesn't check it by
     default
   - **Models:** whichever model IDs are currently loaded in LM Studio. Run
     `curl -s http://localhost:1234/v1/models` with LM Studio's server running
     to see the exact IDs — they don't always match the model's download name.
4. Click **Check Connection**, then **Save**.
5. Under **Agent Config → Add Profile**, create a Claude Code profile using
   this provider, and note its name — you'll reference it in the Playbook
   templates under `playbooks/`.

See CCR's own docs for anything beyond this (provider.md, agent-profile.md in
musistudio/claude-code-router's repo) — this file only covers the values
specific to pairing it with a local LM Studio server.
