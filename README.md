# dotfiles

One command, auto-detects macOS vs Linux:
```
curl -fsSL https://raw.githubusercontent.com/jakeloo/dotfiles/master/install.sh | bash
```

Or run an OS installer directly:
```
curl -fsSL https://raw.githubusercontent.com/jakeloo/dotfiles/master/install-linux.sh | bash
curl -fsSL https://raw.githubusercontent.com/jakeloo/dotfiles/master/install-mac.sh | bash
```

## Provisioning CLI access

The installer only installs binaries. To sign in to the CLIs that need it
(`gh`, 1Password, Claude, Codex, Tailscale), run the provisioner from a real
terminal — sign-in flows need a TTY, so process substitution keeps stdin
attached instead of a bare `curl | bash`:
```
bash <(curl -fsSL https://raw.githubusercontent.com/jakeloo/dotfiles/master/setup-access.sh)
```
It is idempotent — already signed-in CLIs are detected and skipped. Pass names
to provision only a subset, e.g. `setup-access.sh gh op`.

## Layout

- [`versions.env`](versions.env) — pinned tool versions (Go, Node, Python, Rust,
  Neovim, 1Password CLI), shared by both installers. Bump once, both OSes pick it
  up.
- [`lib/common.sh`](lib/common.sh) — shared install steps (config copy, tmux/nvim
  plugins, Go, gopls, Node, Python, Rust). Each `install-*.sh` only handles what
  is genuinely OS-specific (package manager + toolchain bootstrap).
- `install.sh` / `install-mac.sh` / `install-linux.sh` — entrypoints.
- [`setup-access.sh`](setup-access.sh) — interactive, idempotent post-install
  sign-in for CLIs (gh, 1Password, Claude, Codex, Tailscale).

Override the branch the installer pulls config from with
`DOTFILES_REF=<branch> ... | bash`. Installs are idempotent — re-running updates
in place. Language servers and tmux/nvim plugins are installed automatically as
part of the run.
