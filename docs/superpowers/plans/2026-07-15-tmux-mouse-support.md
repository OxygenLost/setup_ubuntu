# Tmux Mouse Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install tmux and ensure each configured user has tmux mouse support enabled without overwriting an existing `~/.tmux.conf`.

**Architecture:** Add a focused tmux section near the existing package-installation steps in `setup_ubuntu.sh`. It installs the Ubuntu package, uses an exact-line guard before appending the mouse option to the user's tmux configuration, and applies the setting to an already-running tmux server. A shell behavior test extracts only that section and executes it under `bash -e` with temporary `HOME` and `PATH` values plus mocked `sudo`, `apt`, and `tmux` commands.

**Tech Stack:** Bash, APT, GNU grep.

---

### Task 1: Add a focused tmux setup test

**Files:**
- Create: `tests/test_tmux_mouse.sh`
- Test: `tests/test_tmux_mouse.sh`

- [ ] **Step 1: Write the failing behavior test**

Extract only the tmux section and execute it with `bash -e` in a temporary `HOME` and `PATH`. Provide mock `sudo`, `apt`, and `tmux` executables so the test does not invoke a real installer or tmux server. Verify that:

- the mocked `apt` receives exactly `install -y tmux`;
- two executions create an absent `~/.tmux.conf` and leave exactly one `set -g mouse on` line;
- an existing `set -g status on` line remains present;
- an active mocked tmux server receives `set-option -g mouse on`;
- cleanup uses a trap.

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/test_tmux_mouse.sh`

Expected: Exit status 1 because the active mocked tmux server has not received `set-option -g mouse on`.

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
if tmux has-session 2>/dev/null; then
  tmux set-option -g mouse on
fi
echo "✓ tmux installed with mouse support"
```

- [ ] **Step 2: Run the focused test to verify it passes**

Run: `bash tests/test_tmux_mouse.sh`

Expected: Exit status 0 after the mocked package install, append-only configuration behavior, and active-server update are verified.

- [ ] **Step 3: Verify script syntax**

Run: `bash -n setup_ubuntu.sh`

Expected: Exit status 0 and no output.

- [ ] **Step 4: Verify test syntax**

Run: `bash -n tests/test_tmux_mouse.sh`

Expected: Exit status 0 and no output.

- [ ] **Step 5: Commit the implementation**

```bash
git add setup_ubuntu.sh tests/test_tmux_mouse.sh docs/superpowers/specs/2026-07-15-tmux-mouse-design.md docs/superpowers/plans/2026-07-15-tmux-mouse-support.md
git commit -m "fix: apply tmux mouse setting to active sessions"
```
