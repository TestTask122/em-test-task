# em-test-task
Скрипт мониторинга процесса 'test' с использованием systemd-таймера.

# Мониторинг процесса через systemd

Bash-скрипт и юниты systemd для отслеживания состояния процесса.

## Принцип работы

1.  **`monitoring.timer`**: systemd-таймер, который срабатывает раз в минуту и запускает `monitoring.service`.
2.  **`monitoring.service`**: systemd-сервис, который выполняет основной скрипт `monitor_test_process.sh`.
3.  **`monitor_test_process.sh`**:
    *   Ищет PID процесса `test`.
    *   Если процесс не найден, завершает работу.
    *   Если процесс найден, сравнивает его PID с сохраненным в `/var/run/monitoring_test.pid`.
    *   Если PID изменился (факт перезапуска) или появился впервые, пишет об этом в лог `/var/log/monitoring.log`.
    *   Отправляет heartbeat-запрос на указанный URL. При ошибке (сетевая недоступность, код 4xx/5xx) пишет в лог.

## Установка

Выполнять с правами `sudo`.

```bash
# 1. Разместить исполняемый скрипт
install -m 755 monitor_test_process.sh /usr/local/bin/

# 2. Разместить юниты systemd
install -m 644 monitoring.service monitoring.timer /etc/systemd/system/

# 3. Создать лог-файл
touch /var/log/monitoring.log

# 4. Перечитать конфигурацию systemd, включить и запустить таймер
systemctl daemon-reload
systemctl enable --now monitoring.timer
```

## Проверка

```bash
# Статус таймера (когда был последний запуск и когда будет следующий)
systemctl status monitoring.timer

# Просмотр логов в реальном времени
tail -f /var/log/monitoring.log
```

## Конфигурация

Параметры задаются в начале файла `monitor_test_process.sh`:

*   `PROCESS_NAME`: Имя отслеживаемого процесса.
*   `API_URL`: URL для heartbeat-запросов.
*   `LOG_FILE`: Путь к файлу логов.
*   `PID_FILE`: Путь к файлу для хранения PID.
