# Tmux Mouse Support

## Goal

Enable tmux mouse interaction on Ubuntu systems configured by `setup_ubuntu.sh`.

## Design

The setup script will add a tmux setup step that:

1. Installs the Ubuntu `tmux` package.
2. Creates `~/.tmux.conf` when it does not exist.
3. Appends `set -g mouse on` only when that exact setting is absent.
4. When a tmux server is already running, applies `tmux set-option -g mouse on` to its active sessions.

This keeps the persisted configuration append-only, idempotent, and protective of existing user tmux settings. The runtime command applies mouse support immediately to an active server without sourcing or overwriting `~/.tmux.conf`; the persisted setting covers future servers.

## Error Handling

The existing `set -e` behavior will stop the script if tmux cannot be installed or the configuration file cannot be updated. The configuration check uses a fixed-string match so commented or unrelated settings are not treated as the enabled setting. `tmux has-session` remains in an `if` conditional, so its nonzero result when no server is running does not stop the setup script.

## Verification

Add a focused script-level behavior test that extracts and executes only the tmux section under `bash -e` with temporary `HOME` and `PATH` values. Mock `sudo`, `apt`, and `tmux` to verify the package arguments, idempotent append-only configuration behavior, preservation of existing settings, and immediate application to an active tmux server. Run the test before and after the implementation, then run `bash -n setup_ubuntu.sh` and `bash -n tests/test_tmux_mouse.sh`.
