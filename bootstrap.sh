#!/usr/bin/env bash
set -euo pipefail

log() {
  echo -e "\n[+] $1"
}

install_uv() {
  if ! command -v uv &>/dev/null; then
    log "Installing uv"
    curl -Ls https://astral.sh/uv/install.sh | sh
  else
    log "uv already installed"
  fi
}

setup_completion() {
  log "Setting up uv completion"

  grep -q "uv completion bash" ~/.bashrc 2>/dev/null ||
    echo 'eval "$(uv completion bash)"' >>~/.bashrc
}

setup_dotfiles() {
  DOTFILES_DIR="$HOME/.dotfiles"

  if [ ! -d "$DOTFILES_DIR" ]; then
    log "Cloning dotfiles"
    git clone https://github.com/pyLerner/dotfiles.git "$DOTFILES_DIR"
  else
    log "Updating dotfiles"
    git -C "$DOTFILES_DIR" pull
  fi

  log "Linking configs"
  ln -sf "$DOTFILES_DIR/tmux.conf" ~/.tmux.conf
  ln -sf "$DOTFILES_DIR/vimrc" ~/.vimrc
}

main() {
  log "Updating system"
  sudo apt update -y

  log "Installing dependencies"
  sudo apt install -y curl git bash-completion

  install_uv
  setup_completion
  setup_dotfiles

  log "Bootstrap complete 🚀"
}

main "$@"
