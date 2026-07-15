# Tmux Mouse Support

## Goal

Enable tmux mouse interaction on Ubuntu systems configured by `setup_ubuntu.sh`.

## Design

The setup script will add a tmux setup step that:

1. Installs the Ubuntu `tmux` package.
2. Creates `~/.tmux.conf` when it does not exist.
3. Appends `set -g mouse on` only when that exact setting is absent.

This keeps the script idempotent and preserves any existing user tmux configuration. tmux will apply the setting to new sessions after the next server restart or when the configuration is reloaded.

## Error Handling

The existing `set -e` behavior will stop the script if tmux cannot be installed or the configuration file cannot be updated. The configuration check uses a fixed-string match so commented or unrelated settings are not treated as the enabled setting.

## Verification

Add a focused script-level test that checks for tmux installation and the guarded `set -g mouse on` configuration. Run the test before and after the implementation, then run `bash -n setup_ubuntu.sh`.
