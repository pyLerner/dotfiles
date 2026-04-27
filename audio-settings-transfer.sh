#!/bin/bash

# Функция для вывода справки
usage() {
    echo "Использование:"
    echo "  Сохранение:  $0 save -o file.tar"
    echo "  Восстановление: $0 -f file.tar"
    exit 1
}

# Проверка наличия аргументов
if [ $# -lt 2 ]; then
    usage
fi

# Временная папка для сбора данных
TMP_DIR=$(mktemp -d /tmp/audio_settings.XXXXXX)

case "$1" in
    save)
        # Обработка флага -o
        if [ "$2" != "-o" ] || [ -z "$3" ]; then usage; fi
        OUTPUT_FILE="$3"
        
        echo "📥 Сохранение настроек звука..."

        # 1. ALSA: сохраняем текущие уровни микшера
        alsactl store -f "$TMP_DIR/alsa_settings.state" 2>/dev/null
        [ -f /etc/asound.conf ] && cp /etc/asound.conf "$TMP_DIR/"
        [ -f "$HOME/.asoundrc" ] && cp "$HOME/.asoundrc" "$TMP_DIR/"

        # 2. PulseAudio: копируем конфиги и базу данных
        if [ -d "$HOME/.config/pulse" ]; then
            cp -r "$HOME/.config/pulse" "$TMP_DIR/pulse_user"
        fi
        if [ -d /etc/pulse ]; then
            cp -r /etc/pulse "$TMP_DIR/pulse_etc"
        fi

        # 3. WirePlumber (на случай, если ОС новее и использует PipeWire)
        if [ -d "$HOME/.local/state/wireplumber" ]; then
            cp -r "$HOME/.local/state/wireplumber" "$TMP_DIR/wireplumber_state"
        fi

        # Создаем tar-архив
        tar -cf "$OUTPUT_FILE" -C "$TMP_DIR" .
        
        # Очистка
        rm -rf "$TMP_DIR"
        echo "✨ Все настройки успешно сохранены в файл: $OUTPUT_FILE"
        ;;

    -f)
        INPUT_FILE="$2"
        if [ ! -f "$INPUT_FILE" ]; then
            echo "❌ Ошибка: Файл $INPUT_FILE не найден!"
            exit 1
        fi

        echo "📤 Восстановление настроек звука..."

        # Распаковываем архив во временную папку
        tar -xf "$INPUT_FILE" -C "$TMP_DIR"

        # 1. Восстановление PulseAudio / PipeWire (останавливаем службы)
        echo "🛑 Остановка аудио-сервисов..."
        systemctl --user stop pulseaudio.service pipewire-pulse.service pipewire.service wireplumber.service 2>/dev/null

        # Восстановление файлов PulseAudio
        if [ -d "$TMP_DIR/pulse_user" ]; then
            rm -rf "$HOME/.config/pulse"
            cp -r "$TMP_DIR/pulse_user" "$HOME/.config/pulse"
        fi
        if [ -d "$TMP_DIR/pulse_etc" ]; then
            echo "🔑 Требуются права sudo для копирования системных конфигов PulseAudio..."
            sudo cp -r "$TMP_DIR/pulse_etc/." /etc/pulse/
        fi

        # Восстановление файлов WirePlumber
        if [ -d "$TMP_DIR/wireplumber_state" ]; then
            rm -rf "$HOME/.local/state/wireplumber"
            cp -r "$TMP_DIR/wireplumber_state" "$HOME/.local/state/wireplumber"
        fi

        # 2. Восстановление ALSA
        if [ -f "$TMP_DIR/.asoundrc" ]; then
            cp "$TMP_DIR/.asoundrc" "$HOME/.asoundrc"
        fi
        if [ -f "$TMP_DIR/asound.conf" ]; then
            echo "🔑 Требуются права sudo для копирования asound.conf..."
            sudo cp "$TMP_DIR/asound.conf" /etc/asound.conf
        fi
        if [ -f "$TMP_DIR/alsa_settings.state" ]; then
            echo "🔑 Требуются права sudo для применения уровней ALSA..."
            sudo alsactl restore -f "$TMP_DIR/alsa_settings.state"
            sudo alsactl store
        fi

        # Запуск аудио-сервисов обратно
        echo "▶️ Перезапуск аудио-сервисов..."
        systemctl --user start pipewire.service 2>/dev/null
        systemctl --user start wireplumber.service 2>/dev/null
        systemctl --user start pipewire-pulse.service 2>/dev/null
        systemctl --user start pulseaudio.service 2>/dev/null

        # Очистка
        rm -rf "$TMP_DIR"
        echo "✨ Настройки успешно применены!"
        ;;

    *)
        usage
        ;;
esac
