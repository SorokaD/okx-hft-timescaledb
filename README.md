# okx-hft-timescaledb

Локальная обвязка для PostgreSQL 16 с расширением TimescaleDB 2.23. Подходит для обкатки ingestion-сценариев и аналитики на локальном хосте перед миграцией на выделенные серверы (например, Hetzнер).

## Быстрый старт
- Установите Docker Desktop (Compose версии v2+).
- Скопируйте `.env` (либо откройте и обновите значения).
- Поднимите сервис: `docker compose up -d`.
- Проверьте состояние и логи: `docker compose ps` и `docker compose logs timescaledb`.
- Подключитесь к БД: `docker compose exec timescaledb psql -U $POSTGRES_USER -d $POSTGRES_DB`.

По умолчанию PostgreSQL слушает порт `5432` на `localhost`.

## Переменные окружения
`docker-compose.yml` использует файл `.env` в корне репозитория:


Перед использованием в общем окружении обязательно измените пароль, а сам файл `.env` храните вне VCS либо в секретах CI/CD.

## Структура проекта
- `docker-compose.yml` — контейнер PostgreSQL 16 + TimescaleDB 2.23 с healthcheck.
- `.env` — параметры суперпользователя `admin`, имя БД, тайм-зона.
- `initdb/` — SQL-скрипты, исполняемые при первом старте (подключение TimescaleDB).
- `volumes/postgres/` — каталог на диске `D:` с данными и конфигурацией PostgreSQL.

Каталог `volumes/` лежит в рабочем репозитории на диске `D:` и поэтому данные физически остаются на локальном SSD/НDD. При миграции на Hetzner можно смонтировать отдельный путь или volume.

## Работа с TimescaleDB
- Расширение подключается автоматически при инициализации пустого data-dir (`initdb/01_enable_timescaledb.sql`).
- Для создания hypertable:
  ```sql
  SELECT create_hypertable('metrics', 'ts');
  ```
- После первой инициализации дальнейшие изменения в папке `initdb/` не применяются автоматически — используйте миграции/psql.

## Эксплуатация
- Перезапуск: `docker compose restart timescaledb`.
- Миграция на другой сервер: перенесите `.env`, `docker-compose.yml` и каталог `volumes/postgres` (или выполните `pg_dump`/`pg_basebackup`).
- Бэкап (пример в tar):
  ```
  docker compose exec timescaledb pg_dump -U $POSTGRES_USER -d $POSTGRES_DB > backup.sql
  ```
- Полная очистка данных: `docker compose down -v` (удалит содержимое `volumes/postgres`).

## Чек-лист перед развёртыванием на Hetzner
- [ ] Установлены уникальные учётные данные администратора.
- [ ] Настроены firewall/ACL для внешних подключений.
- [ ] Организован бэкап (pg_dump, basebackup или snapshot).
- [ ] Определён план мониторинга (pg_exporter, Grafana, Alertmanager).
- [ ] Проверены параметры диска/IOPS под нагрузку.

## Ссылки
- PostgreSQL 16: <https://www.postgresql.org/docs/current/>
- TimescaleDB 2.23: <https://docs.timescale.com/>
- Docker Hub (TimescaleDB): <https://hub.docker.com/r/timescale/timescaledb>