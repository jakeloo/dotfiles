#!/usr/bin/env bash
#
# Interactive post-install access provisioner: sign in to the CLIs the installer
# laid down (gh, 1Password, Claude, Codex, Tailscale, ...). install.sh is
# deliberately non-interactive and only installs binaries; account sign-in needs
# a TTY / browser, so it lives here instead.
#
# Run it from a real terminal (a clone, or `bash <(curl -fsSL .../setup-access.sh)`
# so stdin stays attached to your terminal). It is idempotent: every step detects
# an existing session and skips it, so re-running only fills in what is missing.
#
#   ./setup-access.sh            # provision every known CLI
#   ./setup-access.sh gh op      # only the named ones
#
# No `set -e`: one CLI's sign-in being declined or failing must not abort the
# rest. Steps report their own status and main() prints a summary.
set -uo pipefail

KNOWN="gh op tailscale claude codex"

if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'
  YLW=$'\033[33m'; BLU=$'\033[34m'; RST=$'\033[0m'
else
  BOLD=; DIM=; RED=; GRN=; YLW=; BLU=; RST=
fi

hdr()  { printf '\n%s==>%s %s\n' "$BLU$BOLD" "$RST" "$*"; }
ok()   { printf '  %s+%s %s\n' "$GRN" "$RST" "$*"; }
act()  { printf '  %s>%s %s\n' "$YLW" "$RST" "$*"; }
skip() { printf '  %s.%s %s\n' "$DIM" "$RST" "$*"; }
err()  { printf '  %sx%s %s\n' "$RED" "$RST" "$*"; }

have() { command -v "$1" >/dev/null 2>&1; }

# Each provision_* returns: 0 = signed in, 1 = installed but not completed,
# 2 = not installed (nothing to do).

provision_gh() {
  hdr "GitHub CLI (gh)"
  have gh || { skip "not installed"; return 2; }
  if gh auth status >/dev/null 2>&1; then
    ok "already signed in as $(gh api user --jq .login 2>/dev/null || echo '<unknown>')"
    return 0
  fi
  act "signing in: gh auth login"
  if gh auth login; then ok "signed in"; return 0; fi
  err "sign-in not completed"; return 1
}

provision_op() {
  hdr "1Password CLI (op)"
  have op || { skip "not installed"; return 2; }
  if op account list --format=json 2>/dev/null | grep -q '{'; then
    ok "account already configured"
  else
    act "adding an account: op account add"
    if ! op account add; then err "account not added"; return 1; fi
    ok "account added"
  fi
  # A signin session is per-shell and cannot be exported from this script, so
  # only report it; the user starts one in their own shell when they need it.
  if op whoami >/dev/null 2>&1; then
    ok "active session detected"
  else
    skip "to use op in a shell:  eval \"\$(op signin)\"  (or enable the 1Password app's CLI integration)"
  fi
  return 0
}

provision_tailscale() {
  hdr "Tailscale"
  have tailscale || { skip "not installed"; return 2; }
  if tailscale status >/dev/null 2>&1; then
    ok "already connected"
    return 0
  fi
  act "connecting: sudo tailscale up  (prints an auth URL)"
  if sudo tailscale up; then ok "connected"; return 0; fi
  err "not connected"; return 1
}

provision_claude() {
  hdr "Claude Code (claude)"
  have claude || { skip "not installed"; return 2; }
  if claude auth status >/dev/null 2>&1; then
    ok "already signed in"
    return 0
  fi
  act "signing in: claude auth login"
  if claude auth login; then ok "signed in"; return 0; fi
  err "sign-in not completed"; return 1
}

provision_codex() {
  hdr "Codex CLI (codex)"
  have codex || { skip "not installed"; return 2; }
  if codex login status >/dev/null 2>&1; then
    ok "already signed in"
    return 0
  fi
  act "signing in: codex login"
  if codex login; then ok "signed in"; return 0; fi
  err "sign-in not completed"; return 1
}

dispatch() {
  case "$1" in
    gh)            provision_gh ;;
    op|1password)  provision_op ;;
    tailscale|ts)  provision_tailscale ;;
    claude)        provision_claude ;;
    codex)         provision_codex ;;
    *) err "unknown CLI: $1 (known: $KNOWN)"; return 2 ;;
  esac
}

usage() {
  cat <<USAGE
setup-access.sh - interactively provision access for installed CLIs.

  ./setup-access.sh            provision every known CLI
  ./setup-access.sh gh op      only the named CLIs

Known: $KNOWN

Idempotent - already signed-in CLIs are detected and skipped. Run from a real
terminal; sign-in flows need a TTY (not for a bare \`curl | bash\`).
USAGE
}

main() {
  case "${1:-}" in
    -h|--help) usage; return 0 ;;
  esac

  if ! [ -t 0 ]; then
    echo "setup-access.sh needs an interactive terminal for sign-in flows." >&2
    echo "Run it from a clone, or: bash <(curl -fsSL .../setup-access.sh)" >&2
    return 1
  fi

  local -a steps
  if [ "$#" -gt 0 ]; then steps=("$@"); else steps=(gh op tailscale claude codex); fi

  local ready="" pending="" missing="" s
  for s in "${steps[@]}"; do
    dispatch "$s"
    case "$?" in
      0) ready="$ready $s" ;;
      2) missing="$missing $s" ;;
      *) pending="$pending $s" ;;
    esac
  done

  hdr "Summary"
  [ -n "$ready" ]   && ok   "signed in:$ready"
  [ -n "$pending" ] && act  "needs attention:$pending"
  [ -n "$missing" ] && skip "not installed:$missing"
  return 0
}

main "$@"
