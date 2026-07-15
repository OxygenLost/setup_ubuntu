#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/setup_ubuntu.sh"
test_tmp="$(mktemp -d)"
mock_bin="$test_tmp/bin"
missing_home="$test_tmp/missing-home"
existing_home="$test_tmp/existing-home"
original_path="$PATH"

cleanup() {
  rm -rf "$test_tmp"
}
trap cleanup EXIT

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

assert_file_lines() {
  local file="$1"
  shift
  local expected actual

  expected="$(printf '%s\n' "$@")"
  actual="$(<"$file")"
  [[ "$actual" == "$expected" ]] || fail "Unexpected contents in $file"
}

tmux_section="$(sed -n '/^echo "── tmux (terminal multiplexer)/,/^echo "✓ tmux installed with mouse support"$/p' "$script_path")"
[[ -n "$tmux_section" ]] || fail "Could not extract tmux setup section"

mkdir -p "$mock_bin" "$missing_home" "$existing_home"

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -euo pipefail' \
  'printf "sudo %s\n" "$*" >> "$TEST_TMP/sudo.log"' \
  'exec "$@"' \
  > "$mock_bin/sudo"

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -euo pipefail' \
  'if [[ "$#" -ne 3 || "$1" != "install" || "$2" != "-y" || "$3" != "tmux" ]]; then' \
  '  printf "Unexpected apt arguments: %s\n" "$*" >&2' \
  '  exit 64' \
  'fi' \
  'printf "%s %s %s\n" "$1" "$2" "$3" >> "$TEST_TMP/apt.log"' \
  > "$mock_bin/apt"

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -euo pipefail' \
  'case "$1" in' \
  '  has-session)' \
  '    [[ "${TMUX_ACTIVE:-0}" == "1" ]] && exit 0' \
  '    exit 1' \
  '    ;;' \
  '  set-option)' \
  '    if [[ "$#" -ne 4 || "$2" != "-g" || "$3" != "mouse" || "$4" != "on" ]]; then' \
  '      printf "Unexpected tmux arguments: %s\n" "$*" >&2' \
  '      exit 64' \
  '    fi' \
  '    printf "%s %s %s %s\n" "$1" "$2" "$3" "$4" >> "$TEST_TMP/tmux.log"' \
  '    ;;' \
  '  *)' \
  '    printf "Unexpected tmux command: %s\n" "$*" >&2' \
  '    exit 64' \
  '    ;;' \
  'esac' \
  > "$mock_bin/tmux"

chmod +x "$mock_bin/sudo" "$mock_bin/apt" "$mock_bin/tmux"

run_tmux_section() {
  local home="$1"

  HOME="$home" PATH="$mock_bin:$original_path" TEST_TMP="$test_tmp" TMUX_ACTIVE=1 \
    bash -e -c "$tmux_section" >/dev/null
}

run_tmux_section "$missing_home"
[[ -f "$missing_home/.tmux.conf" ]] || fail 'Expected missing tmux configuration to be created'
run_tmux_section "$missing_home"
assert_file_lines "$missing_home/.tmux.conf" '' '# Enable tmux mouse support.' 'set -g mouse on'

printf '%s\n' 'set -g status on' > "$existing_home/.tmux.conf"
run_tmux_section "$existing_home"
assert_file_lines "$existing_home/.tmux.conf" 'set -g status on' '' '# Enable tmux mouse support.' 'set -g mouse on'

assert_file_lines "$test_tmp/apt.log" 'install -y tmux' 'install -y tmux' 'install -y tmux'
assert_file_lines "$test_tmp/sudo.log" 'sudo apt install -y tmux' 'sudo apt install -y tmux' 'sudo apt install -y tmux'
[[ -f "$test_tmp/tmux.log" ]] \
  || fail 'Expected active tmux server to receive set-option -g mouse on'
assert_file_lines "$test_tmp/tmux.log" 'set-option -g mouse on' 'set-option -g mouse on' 'set-option -g mouse on'
