#!/bin/bash
#
# OS-detecting entrypoint: run this and it dispatches to the right installer.
#   curl -fsSL .../install.sh | bash
#
# Wrapped in main() and invoked on the last line so a truncated `curl | bash`
# download can never execute a partial script.

set -euo pipefail

main() {
  local ref="${DOTFILES_REF:-master}"
  local script
  case "$(uname -s)" in
    Darwin) script="install-mac.sh" ;;
    Linux) script="install-linux.sh" ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac

  echo "Detected $(uname -s); running ${script} (ref ${ref})"
  export DOTFILES_REF="$ref"
  curl -fsSL "https://raw.githubusercontent.com/jakeloo/dotfiles/${ref}/${script}" | bash
}

main "$@"
