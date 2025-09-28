#!/bin/bash

set -euo pipefail

# --- Переменные ---
PROCESS_NAME="test"
API_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
PID_FILE="/var/run/monitoring_test.pid"

# --- Функции ---

# Запись в лог с timestamp (ISO 8601)
log_message() {
    echo "$(date --iso-8601=seconds) $1" >> "$LOG_FILE"
}

# --- Логика ---

# Ищем PID
current_pid=$(pidof -s "$PROCESS_NAME" || true)

if [[ -z "$current_pid" ]]; then
    # Процесс не запущен. Если остался pid-файл от прошлого запуска - удаляем.
    if [[ -f "$PID_FILE" ]]; then
        rm "$PID_FILE"
    fi
    exit 0
fi

last_pid=""
if [[ -f "$PID_FILE" ]]; then
    last_pid=$(cat "$PID_FILE")
fi

# Процесс работает. Сравниваем PID с сохраненным.
if [[ "$current_pid" != "$last_pid" ]]; then
    log_message "RESTARTED: Process '$PROCESS_NAME' running with new PID $current_pid. Old PID was '$last_pid'."
    echo "$current_pid" > "$PID_FILE"
fi

# Heartbeat-запрос к API.
if ! curl -sf --max-time 10 "$API_URL" > /dev/null; then
    log_message "ERROR: API endpoint '$API_URL' unreachable."
fi

exit 0
