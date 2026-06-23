{{ config(materialized='table', schema='marts') }}

WITH fechas_base AS (

    SELECT fecha_venta::date AS fecha
    FROM {{ ref('stg_ventas') }}
    WHERE fecha_venta IS NOT NULL

    UNION

    SELECT fecha_emision::date AS fecha
    FROM {{ ref('stg_pagos') }}
    WHERE fecha_emision IS NOT NULL

    UNION

    SELECT fecha_vencimiento::date AS fecha
    FROM {{ ref('stg_pagos') }}
    WHERE fecha_vencimiento IS NOT NULL

    UNION

    SELECT fecha_pago::date AS fecha
    FROM {{ ref('stg_pagos') }}
    WHERE fecha_pago IS NOT NULL

),

rango_fechas AS (

    SELECT
        MIN(fecha) AS fecha_inicio,
        MAX(fecha) AS fecha_fin
    FROM fechas_base

),

calendario AS (

    SELECT
        GENERATE_SERIES(
            fecha_inicio,
            fecha_fin,
            INTERVAL '1 day'
        )::date AS fecha
    FROM rango_fechas

)

SELECT
    TO_CHAR(fecha, 'YYYYMMDD')::INT AS tiempo_key,
    fecha,

    EXTRACT(YEAR FROM fecha)::INT AS anio,
    EXTRACT(QUARTER FROM fecha)::INT AS trimestre,
    ('T' || EXTRACT(QUARTER FROM fecha)::INT)::TEXT AS nombre_trimestre,

    EXTRACT(MONTH FROM fecha)::INT AS mes,

    CASE EXTRACT(MONTH FROM fecha)::INT
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS nombre_mes,

    TO_CHAR(fecha, 'YYYY-MM') AS anio_mes,
    (EXTRACT(YEAR FROM fecha)::INT * 100 + EXTRACT(MONTH FROM fecha)::INT) AS anio_mes_numero,

    CASE EXTRACT(MONTH FROM fecha)::INT
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END || ' ' || EXTRACT(YEAR FROM fecha)::INT AS mes_anio,

    EXTRACT(DAY FROM fecha)::INT AS dia,
    EXTRACT(DOY FROM fecha)::INT AS dia_anio,

    EXTRACT(ISODOW FROM fecha)::INT AS dia_semana_numero,

    CASE EXTRACT(ISODOW FROM fecha)::INT
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END AS nombre_dia_semana,

    EXTRACT(WEEK FROM fecha)::INT AS semana_anio,

    CASE
        WHEN EXTRACT(ISODOW FROM fecha)::INT IN (6, 7) THEN TRUE
        ELSE FALSE
    END AS es_fin_semana,

    DATE_TRUNC('month', fecha)::date AS inicio_mes,
    (DATE_TRUNC('month', fecha) + INTERVAL '1 month' - INTERVAL '1 day')::date AS fin_mes,
    DATE_TRUNC('quarter', fecha)::date AS inicio_trimestre,
    DATE_TRUNC('year', fecha)::date AS inicio_anio

FROM calendario
ORDER BY fecha