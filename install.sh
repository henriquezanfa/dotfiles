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
link "$DOTFILES/tuicr"            "$HOME/.config/tuicr"
link "$DOTFILES/tt"               "$HOME/.config/kik/tt"
link "$DOTFILES/tmux/.tmux.conf"  "$HOME/.tmux.conf"

if command -v brew >/dev/null && ! command -v sesh >/dev/null; then
  brew install sesh
fi

if command -v cargo >/dev/null; then
  (cd "$DOTFILES/tt" && cargo build --release)
  link "$DOTFILES/tt/target/release/tt" "$HOME/.local/bin/tt"
else
  echo "skip     tt build (cargo not installed)"
fi

command -v tuicr >/dev/null || echo "todo     install tuicr manually"
