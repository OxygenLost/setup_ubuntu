#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/setup_ubuntu.sh"

assert_line() {
  local line="$1"

  if ! grep -Fqx "$line" "$script_path"; then
    printf 'Missing expected line: %s\n' "$line" >&2
    exit 1
  fi
}

assert_line 'sudo apt install -y tmux'
assert_line 'TMUX_CONF="$HOME/.tmux.conf"'
assert_line "if ! grep -qxF 'set -g mouse on' \"\$TMUX_CONF\" 2>/dev/null; then"
assert_line "  printf '\\n# Enable tmux mouse support.\\nset -g mouse on\\n' >> \"\$TMUX_CONF\""
