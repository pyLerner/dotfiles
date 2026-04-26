#!/usr/bin/env bash

# Включаем строгий режим для переменных и пайпов
set -uo pipefail

# 1. Запрашиваем параметры у пользователя
read -p "Введите user@host: " USER_HOST </dev/tty
read -p "Введите Port [по умолчанию 22]: " PORT </dev/tty
PORT=${PORT:-22}

# 2. Попытка получить токен через SSH
CMD="cat /mnt/data/upload/Projects/Infoteh-main-project/.githubtoken"
echo "Попытка получить токен через SSH..."

# Сохраняем токен. Если SSH падает, переменная останется пустой
GIT_TOKEN=$(ssh -p "${PORT}" "${USER_HOST}" "${CMD}" 2>/dev/null) || GIT_TOKEN=""

# 3. Проверка результата SSH и переменной окружения
if [ -z "$GIT_TOKEN" ]; then
    echo "⚠️ Не удалось получить токен через SSH."
    
    # Проверяем, задана ли переменная окружения
    if [ -z "${DEFAULT_TOKEN:-}" ]; then
        echo "❌ Ошибка: Переменная окружения DEFAULT_TOKEN не задана. Прерывание работы."
        exit 1
    fi
    
    echo "ℹ️ Используем токен из переменной окружения DEFAULT_TOKEN."
    GIT_TOKEN="$DEFAULT_TOKEN"
fi

# Формируем безопасный префикс (строго https)
URL_PREFIX="https://oauth2:${GIT_TOKEN}@"

# Включаем выход при любой последующей ошибке
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
