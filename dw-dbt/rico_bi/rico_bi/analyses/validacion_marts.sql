-- =====================================================
-- validacion_marts.sql
-- VALIDACIÓN FINAL DE LA CAPA MARTS
-- Proyecto BI - Corporación Rico S.A.C.
-- PostgreSQL + dbt
-- =====================================================

-- =====================================================
-- 01. CONTEO GENERAL DE TABLAS MARTS
-- =====================================================

SELECT 'dim_cliente' AS tabla, COUNT(*) AS total FROM {{ ref('dim_cliente') }}
UNION ALL
SELECT 'dim_producto', COUNT(*) FROM {{ ref('dim_producto') }}
UNION ALL
SELECT 'dim_vendedor', COUNT(*) FROM {{ ref('dim_vendedor') }}
UNION ALL
SELECT 'dim_almacen', COUNT(*) FROM {{ ref('dim_almacen') }}
UNION ALL
SELECT 'dim_tiempo', COUNT(*) FROM {{ ref('dim_tiempo') }}
UNION ALL
SELECT 'fact_ventas', COUNT(*) FROM {{ ref('fact_ventas') }}
UNION ALL
SELECT 'fact_pagos', COUNT(*) FROM {{ ref('fact_pagos') }};

-- =====================================================
-- 02. VALIDACIÓN DE FACT_VENTAS CONTRA RAW
-- =====================================================

SELECT
    'raw.detalle_ventas' AS tabla,
    COUNT(*) AS total
FROM {{ source('raw', 'detalle_ventas') }}
UNION ALL
SELECT
    'marts.fact_ventas',
    COUNT(*)
FROM {{ ref('fact_ventas') }};

-- =====================================================
-- 03. VALIDACIÓN DE FACT_PAGOS CONTRA RAW
-- =====================================================

SELECT
    'raw.pagos' AS tabla,
    COUNT(*) AS total
FROM {{ source('raw', 'pagos') }}
UNION ALL
SELECT
    'marts.fact_pagos',
    COUNT(*)
FROM {{ ref('fact_pagos') }};

-- =====================================================
-- 04. VALIDACIÓN DE VENTAS FACTURADAS RAW VS MARTS
-- =====================================================

SELECT
    ROUND((SELECT SUM(total_linea) FROM {{ source('raw', 'detalle_ventas') }})::numeric, 2) AS ventas_facturadas_raw,
    ROUND((SELECT SUM(venta_facturada_con_igv) FROM {{ ref('fact_ventas') }})::numeric, 2) AS ventas_facturadas_marts,
    ROUND(
        ABS(
            (SELECT SUM(total_linea) FROM {{ source('raw', 'detalle_ventas') }})
            -
            (SELECT SUM(venta_facturada_con_igv) FROM {{ ref('fact_ventas') }})
        )::numeric,
    2) AS diferencia;

-- =====================================================
-- 05. VALIDACIÓN DE VENTAS NETAS SIN IGV RAW VS MARTS
-- =====================================================

SELECT
    ROUND((SELECT SUM(subtotal) FROM {{ source('raw', 'detalle_ventas') }})::numeric, 2) AS ventas_netas_raw,
    ROUND((SELECT SUM(venta_neta_sin_igv) FROM {{ ref('fact_ventas') }})::numeric, 2) AS ventas_netas_marts,
    ROUND(
        ABS(
            (SELECT SUM(subtotal) FROM {{ source('raw', 'detalle_ventas') }})
            -
            (SELECT SUM(venta_neta_sin_igv) FROM {{ ref('fact_ventas') }})
        )::numeric,
    2) AS diferencia;

-- =====================================================
-- 06. VALIDACIÓN DE PAGOS TOTALES RAW VS MARTS
-- =====================================================

SELECT
    ROUND((SELECT SUM(monto_total) FROM {{ source('raw', 'pagos') }})::numeric, 2) AS pagos_raw,
    ROUND((SELECT SUM(monto_total) FROM {{ ref('fact_pagos') }})::numeric, 2) AS pagos_marts,
    ROUND(
        ABS(
            (SELECT SUM(monto_total) FROM {{ source('raw', 'pagos') }})
            -
            (SELECT SUM(monto_total) FROM {{ ref('fact_pagos') }})
        )::numeric,
    2) AS diferencia;

-- =====================================================
-- 07. INDICADORES GENERALES DE VENTAS
-- Margen principal corregido: venta neta sin IGV - costo
-- =====================================================

SELECT
    ROUND(SUM(venta_facturada_con_igv)::numeric, 2) AS ventas_facturadas_con_igv,
    ROUND(SUM(venta_neta_sin_igv)::numeric, 2) AS ventas_netas_sin_igv,
    ROUND(SUM(igv_monto)::numeric, 2) AS igv_total,
    ROUND(SUM(costo_total)::numeric, 2) AS costo_total,

    ROUND(SUM(margen_bruto)::numeric, 2) AS margen_bruto_correcto,
    ROUND((SUM(margen_bruto) / NULLIF(SUM(venta_neta_sin_igv), 0) * 100)::numeric, 2) AS pct_margen_correcto,

    ROUND(SUM(margen_bruto_con_igv)::numeric, 2) AS margen_referencia_con_igv,
    ROUND((SUM(margen_bruto_con_igv) / NULLIF(SUM(venta_facturada_con_igv), 0) * 100)::numeric, 2) AS pct_margen_referencia_con_igv,

    ROUND(SUM(kilos)::numeric, 2) AS kilos_totales,
    ROUND(SUM(unidades)::numeric, 2) AS unidades_totales,
    COUNT(*) AS lineas_venta,
    COUNT(DISTINCT venta_id) AS total_ventas,
    ROUND((SUM(venta_facturada_con_igv) / NULLIF(COUNT(DISTINCT venta_id), 0))::numeric, 2) AS ticket_promedio_facturado,
    ROUND((SUM(venta_neta_sin_igv) / NULLIF(COUNT(DISTINCT venta_id), 0))::numeric, 2) AS ticket_promedio_neto
FROM {{ ref('fact_ventas') }};

-- =====================================================
-- 08. INDICADORES GENERALES DE PAGOS Y COBRANZA
-- =====================================================

SELECT
    COUNT(*) AS total_pagos,
    ROUND(SUM(monto_total)::numeric, 2) AS monto_total,
    ROUND(SUM(monto_pagado)::numeric, 2) AS monto_pagado,
    ROUND(SUM(saldo_pendiente)::numeric, 2) AS saldo_pendiente,
    ROUND((SUM(monto_pagado) / NULLIF(SUM(monto_total), 0) * 100)::numeric, 2) AS pct_cobrado,
    ROUND((SUM(saldo_pendiente) / NULLIF(SUM(monto_total), 0) * 100)::numeric, 2) AS pct_pendiente,
    ROUND((AVG(dias_cobro) FILTER (WHERE dias_cobro IS NOT NULL))::numeric, 2) AS dso_promedio,
    ROUND(AVG(dias_atraso)::numeric, 2) AS dias_atraso_promedio,
    SUM(CASE WHEN es_credito THEN 1 ELSE 0 END) AS pagos_credito,
    SUM(CASE WHEN NOT es_credito THEN 1 ELSE 0 END) AS pagos_contado,
    SUM(CASE WHEN es_en_mora THEN 1 ELSE 0 END) AS pagos_en_mora,
    SUM(CASE WHEN es_pendiente THEN 1 ELSE 0 END) AS pagos_pendientes
FROM {{ ref('fact_pagos') }};

-- =====================================================
-- 09. COBRANZA POR ESTADO DE PAGO
-- =====================================================

SELECT
    estado_pago,
    COUNT(*) AS cantidad_pagos,
    ROUND(SUM(monto_total)::numeric, 2) AS monto_total,
    ROUND(SUM(monto_pagado)::numeric, 2) AS monto_pagado,
    ROUND(SUM(saldo_pendiente)::numeric, 2) AS saldo_pendiente,
    ROUND(SUM(monto_vencido)::numeric, 2) AS monto_vencido
FROM {{ ref('fact_pagos') }}
GROUP BY estado_pago
ORDER BY monto_total DESC;

-- =====================================================
-- 10. PAGOS AL CRÉDITO VS CONTADO
-- =====================================================

SELECT
    CASE
        WHEN es_credito = TRUE THEN 'Crédito'
        ELSE 'Contado'
    END AS tipo_operacion,
    COUNT(*) AS cantidad_pagos,
    ROUND(SUM(monto_total)::numeric, 2) AS monto_total,
    ROUND(SUM(monto_pagado)::numeric, 2) AS monto_pagado,
    ROUND(SUM(saldo_pendiente)::numeric, 2) AS saldo_pendiente,
    ROUND(SUM(monto_credito)::numeric, 2) AS monto_credito,
    ROUND(SUM(monto_contado)::numeric, 2) AS monto_contado,
    ROUND(SUM(monto_vencido)::numeric, 2) AS monto_vencido,
    ROUND((AVG(dias_cobro) FILTER (WHERE dias_cobro IS NOT NULL))::numeric, 2) AS dso_promedio,
    ROUND(AVG(dias_atraso)::numeric, 2) AS dias_atraso_promedio
FROM {{ ref('fact_pagos') }}
GROUP BY
    CASE
        WHEN es_credito = TRUE THEN 'Crédito'
        ELSE 'Contado'
    END
ORDER BY monto_total DESC;

-- =====================================================
-- 11. TOP 10 PRODUCTOS POR VENTAS
-- =====================================================

SELECT
    dp.nombre_producto,
    dp.categoria,
    ROUND(SUM(fv.venta_facturada_con_igv)::numeric, 2) AS ventas_facturadas_con_igv,
    ROUND(SUM(fv.venta_neta_sin_igv)::numeric, 2) AS ventas_netas_sin_igv,
    ROUND(SUM(fv.costo_total)::numeric, 2) AS costo_total,
    ROUND(SUM(fv.margen_bruto)::numeric, 2) AS margen_bruto_correcto,
    ROUND((SUM(fv.margen_bruto) / NULLIF(SUM(fv.venta_neta_sin_igv), 0) * 100)::numeric, 2) AS pct_margen,
    ROUND(SUM(fv.kilos)::numeric, 2) AS kilos_vendidos,
    ROUND(SUM(fv.unidades)::numeric, 2) AS unidades_vendidas
FROM {{ ref('fact_ventas') }} fv
INNER JOIN {{ ref('dim_producto') }} dp
    ON fv.producto_key = dp.producto_key
GROUP BY
    dp.nombre_producto,
    dp.categoria
ORDER BY ventas_facturadas_con_igv DESC
LIMIT 10;

-- =====================================================
-- 12. TOP 10 CLIENTES POR VENTAS
-- =====================================================

SELECT
    dc.razon_social,
    dc.tipo_cliente,
    dc.ciudad,
    ROUND(SUM(fv.venta_facturada_con_igv)::numeric, 2) AS ventas_facturadas_con_igv,
    ROUND(SUM(fv.venta_neta_sin_igv)::numeric, 2) AS ventas_netas_sin_igv,
    ROUND(SUM(fv.margen_bruto)::numeric, 2) AS margen_bruto_correcto,
    COUNT(DISTINCT fv.venta_id) AS cantidad_ventas,
    ROUND((SUM(fv.venta_facturada_con_igv) / NULLIF(COUNT(DISTINCT fv.venta_id), 0))::numeric, 2) AS ticket_promedio
FROM {{ ref('fact_ventas') }} fv
INNER JOIN {{ ref('dim_cliente') }} dc
    ON fv.cliente_key = dc.cliente_key
GROUP BY
    dc.razon_social,
    dc.tipo_cliente,
    dc.ciudad
ORDER BY ventas_facturadas_con_igv DESC
LIMIT 10;

-- =====================================================
-- 13. VENTAS POR VENDEDOR
-- =====================================================

SELECT
    dv.nombre_vendedor,
    dv.zona,
    ROUND(SUM(fv.venta_facturada_con_igv)::numeric, 2) AS ventas_facturadas_con_igv,
    ROUND(SUM(fv.venta_neta_sin_igv)::numeric, 2) AS ventas_netas_sin_igv,
    ROUND(SUM(fv.margen_bruto)::numeric, 2) AS margen_bruto_correcto,
    ROUND((SUM(fv.margen_bruto) / NULLIF(SUM(fv.venta_neta_sin_igv), 0) * 100)::numeric, 2) AS pct_margen,
    COUNT(DISTINCT fv.venta_id) AS cantidad_ventas
FROM {{ ref('fact_ventas') }} fv
INNER JOIN {{ ref('dim_vendedor') }} dv
    ON fv.vendedor_key = dv.vendedor_key
GROUP BY
    dv.nombre_vendedor,
    dv.zona
ORDER BY ventas_facturadas_con_igv DESC;

-- =====================================================
-- 14. COBRANZA POR VENDEDOR
-- =====================================================

SELECT
    dv.nombre_vendedor,
    dv.zona,
    COUNT(*) AS cantidad_pagos,
    ROUND(SUM(fp.monto_total)::numeric, 2) AS monto_total,
    ROUND(SUM(fp.monto_pagado)::numeric, 2) AS monto_pagado,
    ROUND(SUM(fp.saldo_pendiente)::numeric, 2) AS saldo_pendiente,
    ROUND((SUM(fp.monto_pagado) / NULLIF(SUM(fp.monto_total), 0) * 100)::numeric, 2) AS pct_cobrado,
    ROUND(SUM(fp.monto_vencido)::numeric, 2) AS monto_vencido,
    SUM(CASE WHEN fp.es_en_mora THEN 1 ELSE 0 END) AS pagos_en_mora
FROM {{ ref('fact_pagos') }} fp
INNER JOIN {{ ref('dim_vendedor') }} dv
    ON fp.vendedor_key = dv.vendedor_key
GROUP BY
    dv.nombre_vendedor,
    dv.zona
ORDER BY saldo_pendiente DESC;

-- =====================================================
-- 15. VENTAS POR ALMACÉN
-- =====================================================

SELECT
    da.nombre_almacen,
    da.ciudad,
    ROUND(SUM(fv.venta_facturada_con_igv)::numeric, 2) AS ventas_facturadas_con_igv,
    ROUND(SUM(fv.venta_neta_sin_igv)::numeric, 2) AS ventas_netas_sin_igv,
    ROUND(SUM(fv.margen_bruto)::numeric, 2) AS margen_bruto_correcto,
    COUNT(DISTINCT fv.venta_id) AS cantidad_ventas
FROM {{ ref('fact_ventas') }} fv
INNER JOIN {{ ref('dim_almacen') }} da
    ON fv.almacen_key = da.almacen_key
GROUP BY
    da.nombre_almacen,
    da.ciudad
ORDER BY ventas_facturadas_con_igv DESC;

-- =====================================================
-- 16. VENTAS POR AÑO Y MES
-- =====================================================

SELECT
    dt.anio,
    dt.mes,
    dt.nombre_mes,
    dt.anio_mes,
    ROUND(SUM(fv.venta_facturada_con_igv)::numeric, 2) AS ventas_facturadas_con_igv,
    ROUND(SUM(fv.venta_neta_sin_igv)::numeric, 2) AS ventas_netas_sin_igv,
    ROUND(SUM(fv.margen_bruto)::numeric, 2) AS margen_bruto_correcto,
    ROUND((SUM(fv.margen_bruto) / NULLIF(SUM(fv.venta_neta_sin_igv), 0) * 100)::numeric, 2) AS pct_margen,
    COUNT(DISTINCT fv.venta_id) AS cantidad_ventas
FROM {{ ref('fact_ventas') }} fv
INNER JOIN {{ ref('dim_tiempo') }} dt
    ON fv.tiempo_key = dt.tiempo_key
GROUP BY
    dt.anio,
    dt.mes,
    dt.nombre_mes,
    dt.anio_mes
ORDER BY
    dt.anio,
    dt.mes;

-- =====================================================
-- 17. CARTERA VENCIDA POR CLIENTE
-- =====================================================

SELECT
    dc.razon_social,
    dc.tipo_cliente,
    dc.ciudad,
    COUNT(*) AS pagos_pendientes,
    ROUND(SUM(fp.monto_total)::numeric, 2) AS monto_total,
    ROUND(SUM(fp.saldo_pendiente)::numeric, 2) AS saldo_pendiente,
    ROUND(SUM(fp.monto_vencido)::numeric, 2) AS monto_vencido,
    ROUND(AVG(fp.dias_atraso)::numeric, 2) AS dias_atraso_promedio
FROM {{ ref('fact_pagos') }} fp
INNER JOIN {{ ref('dim_cliente') }} dc
    ON fp.cliente_key = dc.cliente_key
WHERE fp.es_pendiente = TRUE
GROUP BY
    dc.razon_social,
    dc.tipo_cliente,
    dc.ciudad
ORDER BY monto_vencido DESC
LIMIT 10;

-- =====================================================
-- 18. VALIDACIÓN DE CALENDARIO CONTINUO
-- =====================================================

SELECT
    MIN(fecha) AS fecha_inicio,
    MAX(fecha) AS fecha_fin,
    COUNT(*) AS total_fechas,
    ((MAX(fecha) - MIN(fecha)) + 1)::int AS dias_esperados,
    COUNT(*) - ((MAX(fecha) - MIN(fecha)) + 1)::int AS diferencia
FROM {{ ref('dim_tiempo') }};

-- =====================================================
-- 19. VALIDACIÓN DE FECHAS FALTANTES EN DIM_TIEMPO
-- =====================================================

WITH dias AS (
    SELECT GENERATE_SERIES(
        (SELECT MIN(fecha) FROM {{ ref('dim_tiempo') }}),
        (SELECT MAX(fecha) FROM {{ ref('dim_tiempo') }}),
        INTERVAL '1 day'
    )::date AS fecha
)

SELECT
    COUNT(*) AS fechas_faltantes
FROM dias d
LEFT JOIN {{ ref('dim_tiempo') }} dt
    ON d.fecha = dt.fecha
WHERE dt.fecha IS NULL;

-- =====================================================
-- 20. VALIDACIÓN DE CLAVES DE FECHA SIN DIMENSIÓN
-- =====================================================

SELECT 'fact_ventas_tiempo_key' AS campo, COUNT(*) AS claves_sin_dim
FROM {{ ref('fact_ventas') }} fv
LEFT JOIN {{ ref('dim_tiempo') }} dt
    ON fv.tiempo_key = dt.tiempo_key
WHERE dt.tiempo_key IS NULL

UNION ALL

SELECT 'fact_pagos_tiempo_key', COUNT(*)
FROM {{ ref('fact_pagos') }} fp
LEFT JOIN {{ ref('dim_tiempo') }} dt
    ON fp.tiempo_key = dt.tiempo_key
WHERE dt.tiempo_key IS NULL

UNION ALL

SELECT 'fact_pagos_tiempo_venta_key', COUNT(*)
FROM {{ ref('fact_pagos') }} fp
LEFT JOIN {{ ref('dim_tiempo') }} dt
    ON fp.tiempo_venta_key = dt.tiempo_key
WHERE fp.tiempo_venta_key IS NOT NULL
  AND dt.tiempo_key IS NULL

UNION ALL

SELECT 'fact_pagos_tiempo_emision_key', COUNT(*)
FROM {{ ref('fact_pagos') }} fp
LEFT JOIN {{ ref('dim_tiempo') }} dt
    ON fp.tiempo_emision_key = dt.tiempo_key
WHERE fp.tiempo_emision_key IS NOT NULL
  AND dt.tiempo_key IS NULL

UNION ALL

SELECT 'fact_pagos_tiempo_vencimiento_key', COUNT(*)
FROM {{ ref('fact_pagos') }} fp
LEFT JOIN {{ ref('dim_tiempo') }} dt
    ON fp.tiempo_vencimiento_key = dt.tiempo_key
WHERE fp.tiempo_vencimiento_key IS NOT NULL
  AND dt.tiempo_key IS NULL

UNION ALL

SELECT 'fact_pagos_tiempo_pago_key', COUNT(*)
FROM {{ ref('fact_pagos') }} fp
LEFT JOIN {{ ref('dim_tiempo') }} dt
    ON fp.tiempo_pago_key = dt.tiempo_key
WHERE fp.tiempo_pago_key IS NOT NULL
  AND dt.tiempo_key IS NULL;