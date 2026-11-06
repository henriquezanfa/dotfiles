#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local target="$1" name="$2"
  mkdir -p "$(dirname "$name")"
  if [ -L "$name" ] && [ "$(readlink "$name")" = "$target" ]; then
    echo "ok       $name"
    return
  fi
  if [ -e "$name" ] || [ -L "$name" ]; then
    mv "$name" "$name.bak.$(date +%s)"
    echo "backup   $name -> $name.bak.*"
  fi
  ln -s "$target" "$name"
  echo "linked   $name -> $target"
}

link "$DOTFILES/nvim"             "$HOME/.config/nvim"
link "$DOTFILES/workmux"          "$HOME/.config/workmux"
link "$DOTFILES/sesh"             "$HOME/.config/sesh"
link "$DOTFILES/theme"             "$HOME/.config/theme"
link "$DOTFILES/tuicr"            "$HOME/.config/tuicr"
link "$DOTFILES/tt"               "$HOME/.config/kik/tt"
link "$DOTFILES/tmux/.tmux.conf"  "$HOME/.tmux.conf"
link "$DOTFILES/zsh/.zshrc"       "$HOME/.zshrc"

if [ ! -e "$DOTFILES/sesh/sesh.local.toml" ]; then
  echo "# Machine-local sesh sessions (gitignored)" > "$DOTFILES/sesh/sesh.local.toml"
  echo "created  sesh/sesh.local.toml (add machine-specific sessions)"
fi

if [ ! -e "$HOME/.zshrc.local" ]; then
  cp "$DOTFILES/zsh/zshrc.local.example" "$HOME/.zshrc.local"
  chmod 600 "$HOME/.zshrc.local"
  echo "created  ~/.zshrc.local (fill in secrets)"
fi

if command -v brew >/dev/null; then
  for pkg in sesh fzf fd; do
    command -v "$pkg" >/dev/null || brew install "$pkg"
  done
fi

if command -v cargo >/dev/null; then
  (cd "$DOTFILES/tt" && cargo build --release)
  link "$DOTFILES/tt/target/release/tt" "$HOME/.local/bin/tt"
else
  echo "skip     tt build (cargo not installed)"
fi

command -v tuicr >/dev/null || echo "todo     install tuicr manually"
