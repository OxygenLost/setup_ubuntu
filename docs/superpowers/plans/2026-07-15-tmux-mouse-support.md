# Tmux Mouse Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install tmux and ensure each configured user has tmux mouse support enabled without overwriting an existing `~/.tmux.conf`.

**Architecture:** Add a focused tmux section near the existing package-installation steps in `setup_ubuntu.sh`. It installs the Ubuntu package, then uses an exact-line guard before appending the mouse option to the user's tmux configuration. A shell test statically checks the required package command and idempotent configuration block without executing the installer.

**Tech Stack:** Bash, APT, GNU grep.

---

### Task 1: Add a focused tmux setup test

**Files:**
- Create: `tests/test_tmux_mouse.sh`
- Test: `tests/test_tmux_mouse.sh`

- [ ] **Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/setup_ubuntu.sh"

assert_line() {
  if ! grep -Fqx "$1" "$script_path"; then
    printf 'Missing expected line: %s\n' "$1" >&2
    exit 1
  fi
}

assert_line 'sudo apt install -y tmux'
assert_line 'TMUX_CONF="$HOME/.tmux.conf"'
assert_line "if ! grep -qxF 'set -g mouse on' \"\$TMUX_CONF\" 2>/dev/null; then"
assert_line "  printf '\\n# Enable tmux mouse support.\\nset -g mouse on\\n' >> \"\$TMUX_CONF\""
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/test_tmux_mouse.sh`

Expected: Exit status 1 and `Missing expected line: sudo apt install -y tmux`.

### Task 2: Install and configure tmux

**Files:**
- Modify: `setup_ubuntu.sh:83` before the `tree + broot` section
- Test: `tests/test_tmux_mouse.sh`

- [ ] **Step 1: Add the minimal tmux section**

```bash
echo ""
echo "── tmux (terminal multiplexer) ────────────────────────"
sudo apt install -y tmux
TMUX_CONF="$HOME/.tmux.conf"
if ! grep -qxF 'set -g mouse on' "$TMUX_CONF" 2>/dev/null; then
  printf '\n# Enable tmux mouse support.\nset -g mouse on\n' >> "$TMUX_CONF"
fi
echo "✓ tmux installed with mouse support"
```

- [ ] **Step 2: Run the focused test to verify it passes**

Run: `bash tests/test_tmux_mouse.sh`

Expected: Exit status 0 and no output.

- [ ] **Step 3: Verify script syntax**

Run: `bash -n setup_ubuntu.sh`

Expected: Exit status 0 and no output.

- [ ] **Step 4: Commit the implementation**

```bash
git add setup_ubuntu.sh tests/test_tmux_mouse.sh docs/superpowers/plans/2026-07-15-tmux-mouse-support.md
git commit -m "feat: enable tmux mouse support"
```
