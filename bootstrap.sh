#!/usr/bin/env bash

# Включаем строгий режим сразу (кроме -e на момент получения токена)
set -uo pipefail

# 1. Сначала запрашиваем параметры у пользователя
read -p "Введите user@host: " USER_HOST
read -p "Введите Port [по умолчанию 22]: " PORT
PORT=${PORT:-22} # Если порт не ввели, ставим 22

# 2. Переменные для команды
CMD="cat /mnt/data/upload/Projects/Infoteh-main-project/.githubtoken"

# 3. Вычисляем токен (если ssh упадет, сработает || и запишется DEFAULT)
# Из переменной окружения принимаем DEFAULT_TOKEN
GIT_TOKEN=$(ssh -p "${PORT}" "${USER_HOST}" "${CMD}" 2>/dev/null) || GIT_TOKEN="$DEFAULT_TOKEN"

URL_PREFIX="https://oauth2:${GIT_TOKEN}@"

# Теперь можно включить выход при любой ошибке
set -e


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
  log "Setting up uv & uvx completion"

  grep -q "uv generate-shell-completion bash" ~/.bashrc 2>/dev/null ||
    echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc

  grep -q "uvx --generate-shell-completion bash" ~/.bashrc 2>/dev/null ||
    echo 'eval "$(uvx --generate-shell-completion bash)"' >> ~/.bashrc

}

setup_dotfiles() {
  DOTFILES_DIR="$HOME/.dotfiles"

  if [ ! -d "$DOTFILES_DIR" ]; then
    log "Cloning dotfiles"
    git clone "${URL_PREFIX}"github.com/pyLerner/dotfiles.git "$DOTFILES_DIR"
  else
    log "Updating dotfiles"
    git -C "$DOTFILES_DIR" pull
  fi

  log "Linking configs"
  ln -sf "$DOTFILES_DIR/.tmux.conf" ~/.tmux.conf
  ln -sf "$DOTFILES_DIR/.vimrc" ~/.vimrc
}

main() {
  log "Updating system"
  sudo apt update -y

  log "Installing dependencies"
  sudo apt install -y curl git bash-completion tmux can-utils

  install_uv
  setup_completion
  setup_dotfiles

  log "Bootstrap complete 🚀"
}

main "$@"
