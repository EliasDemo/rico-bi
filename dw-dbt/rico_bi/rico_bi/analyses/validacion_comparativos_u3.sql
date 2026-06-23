-- ============================================================
-- VALIDACIÓN COMPARATIVOS U3
-- Periodo validado en Power BI:
-- Año = 2025
-- Mes = Enero
-- ============================================================

WITH parametros AS (
    SELECT
        2025::INT AS anio_actual,
        1::INT AS mes_actual,
        MAKE_DATE(2025, 1, 1) AS fecha_periodo
),

base AS (
    -- Ventas del periodo actual
    SELECT
        'actual' AS tipo_periodo,
        dp.categoria,
        fv.venta_facturada_con_igv AS venta
    FROM marts.fact_ventas fv
    INNER JOIN marts.dim_tiempo dt
        ON fv.tiempo_key = dt.tiempo_key
    INNER JOIN marts.dim_producto dp
        ON fv.producto_key = dp.producto_key
    CROSS JOIN parametros p
    WHERE dt.anio = p.anio_actual
      AND dt.mes = p.mes_actual

    UNION ALL

    -- Ventas del mismo mes del año anterior
    SELECT
        'anio_anterior' AS tipo_periodo,
        dp.categoria,
        fv.venta_facturada_con_igv AS venta
    FROM marts.fact_ventas fv
    INNER JOIN marts.dim_tiempo dt
        ON fv.tiempo_key = dt.tiempo_key
    INNER JOIN marts.dim_producto dp
        ON fv.producto_key = dp.producto_key
    CROSS JOIN parametros p
    WHERE dt.anio = p.anio_actual - 1
      AND dt.mes = p.mes_actual

    UNION ALL

    -- Ventas del mes anterior
    SELECT
        'mes_anterior' AS tipo_periodo,
        dp.categoria,
        fv.venta_facturada_con_igv AS venta
    FROM marts.fact_ventas fv
    INNER JOIN marts.dim_tiempo dt
        ON fv.tiempo_key = dt.tiempo_key
    INNER JOIN marts.dim_producto dp
        ON fv.producto_key = dp.producto_key
    CROSS JOIN parametros p
    WHERE dt.anio = EXTRACT(YEAR FROM p.fecha_periodo - INTERVAL '1 month')::INT
      AND dt.mes = EXTRACT(MONTH FROM p.fecha_periodo - INTERVAL '1 month')::INT
),

comparativo_categoria AS (
    SELECT
        categoria,
        SUM(CASE WHEN tipo_periodo = 'actual' THEN venta ELSE 0 END) AS ventas_actuales,
        SUM(CASE WHEN tipo_periodo = 'anio_anterior' THEN venta ELSE 0 END) AS ventas_anio_anterior,
        SUM(CASE WHEN tipo_periodo = 'mes_anterior' THEN venta ELSE 0 END) AS ventas_mes_anterior
    FROM base
    GROUP BY categoria
),

resultado AS (
    SELECT
        categoria,
        ventas_actuales,
        ventas_anio_anterior,
        ventas_actuales - ventas_anio_anterior AS variacion_yoy,
        CASE
            WHEN ventas_anio_anterior = 0 THEN NULL
            ELSE ((ventas_actuales - ventas_anio_anterior) / ventas_anio_anterior) * 100
        END AS porcentaje_yoy,
        ventas_mes_anterior,
        ventas_actuales - ventas_mes_anterior AS variacion_mom,
        CASE
            WHEN ventas_mes_anterior = 0 THEN NULL
            ELSE ((ventas_actuales - ventas_mes_anterior) / ventas_mes_anterior) * 100
        END AS porcentaje_mom
    FROM comparativo_categoria

    UNION ALL

    SELECT
        'TOTAL' AS categoria,
        SUM(ventas_actuales),
        SUM(ventas_anio_anterior),
        SUM(ventas_actuales) - SUM(ventas_anio_anterior),
        CASE
            WHEN SUM(ventas_anio_anterior) = 0 THEN NULL
            ELSE ((SUM(ventas_actuales) - SUM(ventas_anio_anterior)) / SUM(ventas_anio_anterior)) * 100
        END,
        SUM(ventas_mes_anterior),
        SUM(ventas_actuales) - SUM(ventas_mes_anterior),
        CASE
            WHEN SUM(ventas_mes_anterior) = 0 THEN NULL
            ELSE ((SUM(ventas_actuales) - SUM(ventas_mes_anterior)) / SUM(ventas_mes_anterior)) * 100
        END
    FROM comparativo_categoria
)

SELECT
    categoria,
    ROUND(ventas_actuales::NUMERIC, 2) AS ventas_actuales,
    ROUND(ventas_anio_anterior::NUMERIC, 2) AS ventas_anio_anterior,
    ROUND(variacion_yoy::NUMERIC, 2) AS variacion_yoy,
    ROUND(porcentaje_yoy::NUMERIC, 2) AS porcentaje_yoy,
    ROUND(ventas_mes_anterior::NUMERIC, 2) AS ventas_mes_anterior,
    ROUND(variacion_mom::NUMERIC, 2) AS variacion_mom,
    ROUND(porcentaje_mom::NUMERIC, 2) AS porcentaje_mom
FROM resultado
ORDER BY
    CASE WHEN categoria = 'TOTAL' THEN 2 ELSE 1 END,
    categoria;