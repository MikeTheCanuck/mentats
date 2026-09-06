#!/usr/bin/env bash
set -euo pipefail

LM_STUDIO_URL="${MENTATS_LM_STUDIO_URL:-http://localhost:1234/v1}"

fail() {
  echo "Error: $1" >&2
  exit 1
}

echo "== Mentats installer =="
echo

echo "Checking prerequisites..."
if [[ "$(uname)" != "Darwin" ]]; then
  fail "Mentats v1 is macOS-only. See CONTRIBUTING.md if you want to help add support for your platform."
fi

if ! command -v brew >/dev/null 2>&1; then
  fail "Homebrew is required but not found. Install it from https://brew.sh, then re-run this script."
fi

echo "  macOS: confirmed"
echo "  Homebrew: found"
echo

echo "Checking claude-code-router..."
if command -v ccr >/dev/null 2>&1; then
  echo "  claude-code-router: already installed ($(ccr --version 2>/dev/null || echo 'version unknown'))"
else
  echo "  claude-code-router: installing via npm..."
  if ! command -v npm >/dev/null 2>&1; then
    fail "npm is required to install claude-code-router but was not found. Install Node.js (e.g. 'brew install node' or via fnm/nvm), then re-run this script."
  fi
  npm install -g @musistudio/claude-code-router
  if ! command -v ccr >/dev/null 2>&1; then
    fail "claude-code-router installed via npm but 'ccr' is not on PATH. Check that npm's global bin directory (run 'npm bin -g' to see it) is on your PATH, then re-run this script."
  fi
  echo "  claude-code-router: installed"
fi
echo

echo "Checking for a local LM Studio server at $LM_STUDIO_URL..."
if curl -s --max-time 3 "$LM_STUDIO_URL/models" >/dev/null 2>&1; then
  echo "  LM Studio: reachable"
else
  fail "No LM Studio server responding at $LM_STUDIO_URL. Start LM Studio's local server (Developer tab -> Server -> Start) and re-run this script, or set MENTATS_LM_STUDIO_URL if it's running on a different port."
fi
echo

echo "== Next steps =="
echo "1. Configure CCR's provider for LM Studio manually — CCR has no file-based"
echo "   config, so this is a GUI step. See: config/ccr-provider-values.md"
echo "2. Install Maestro from its own GitHub Releases page (not automated by"
echo "   this script — it's a proprietary desktop app)."
echo "3. See playbooks/ for example Maestro Playbook templates, and"
echo "   docs/architecture.md for why they're structured this way."
