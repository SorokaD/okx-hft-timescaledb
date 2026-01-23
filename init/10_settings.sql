-- ============================================================
-- PostgreSQL / TimescaleDB performance settings
-- ============================================================
-- NOTE: PgBouncer используется как connection pooler перед PostgreSQL
-- Прямые соединения только от внутренних сервисов (postgres-exporter)

-- Лимит соединений (с PgBouncer не нужно много)
-- PgBouncer max_db_connections=50 + exporter + superuser reserve
ALTER SYSTEM SET max_connections = 100;
ALTER SYSTEM SET superuser_reserved_connections = 5;

-- Shared buffers (рекомендуется 25% RAM)
-- При 8GB RAM = 2GB
ALTER SYSTEM SET shared_buffers = '2GB';

-- Work mem для сортировок и джойнов
ALTER SYSTEM SET work_mem = '64MB';

-- Maintenance work mem (для VACUUM, CREATE INDEX)
ALTER SYSTEM SET maintenance_work_mem = '512MB';

-- Effective cache size (рекомендуется 50-75% RAM)
ALTER SYSTEM SET effective_cache_size = '4GB';

-- WAL settings для лучшей производительности
ALTER SYSTEM SET wal_buffers = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;

-- Логирование медленных запросов (> 1 сек)
ALTER SYSTEM SET log_min_duration_statement = 1000;

-- TimescaleDB specific
ALTER SYSTEM SET timescaledb.max_background_workers = 8;
