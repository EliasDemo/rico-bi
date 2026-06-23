-- =====================================================
-- 01_init_dw_pg.sql
-- Inicialización de PostgreSQL DW
-- Proyecto BI - Corporación Rico S.A.C.
-- =====================================================

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;

-- Validación
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('raw', 'staging', 'marts')
ORDER BY schema_name;