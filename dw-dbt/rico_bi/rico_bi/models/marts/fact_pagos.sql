{{ config(materialized='table', schema='marts') }}

WITH base AS (

    SELECT
        p.pago_id AS pago_key,

        -- Clave antigua conservada para compatibilidad con el modelo actual.
        -- Representa la fecha de emisión del pago/documento.
        TO_CHAR(p.fecha_emision, 'YYYYMMDD')::INT AS tiempo_key,

        -- Nuevas claves de fecha para análisis de cobranza.
        TO_CHAR(v.fecha_venta, 'YYYYMMDD')::INT AS tiempo_venta_key,
        TO_CHAR(p.fecha_emision, 'YYYYMMDD')::INT AS tiempo_emision_key,
        TO_CHAR(p.fecha_vencimiento, 'YYYYMMDD')::INT AS tiempo_vencimiento_key,

        CASE
            WHEN p.fecha_pago IS NOT NULL
                THEN TO_CHAR(p.fecha_pago, 'YYYYMMDD')::INT
            ELSE NULL
        END AS tiempo_pago_key,

        v.cliente_id AS cliente_key,
        v.vendedor_id AS vendedor_key,
        v.almacen_id AS almacen_key,

        p.pago_id,
        p.venta_id,

        v.tipo_doc,
        v.serie,
        v.numero_doc,
        v.estado AS estado_venta,
        p.tipo_pago,
        p.estado_pago,

        v.fecha_venta,
        p.fecha_emision,
        p.fecha_vencimiento,
        p.fecha_pago,

        p.plazo_dias,

        p.monto_total,
        p.monto_pagado,
        p.saldo_pendiente,

        p.dias_mora,
        p.es_credito,

        -- Días reales de cobro: solo aplica cuando existe fecha de pago.
        CASE
            WHEN p.fecha_pago IS NOT NULL
                THEN (p.fecha_pago::date - p.fecha_emision::date)
            ELSE NULL
        END AS dias_cobro,

        -- Días pactados entre emisión y vencimiento.
        CASE
            WHEN p.fecha_vencimiento IS NOT NULL
                 AND p.fecha_emision IS NOT NULL
                THEN (p.fecha_vencimiento::date - p.fecha_emision::date)
            ELSE NULL
        END AS dias_credito_programado,

        -- Días de atraso considerando pagos realizados y documentos pendientes.
        CASE
            WHEN p.fecha_pago IS NOT NULL
                 AND p.fecha_vencimiento IS NOT NULL
                THEN GREATEST((p.fecha_pago::date - p.fecha_vencimiento::date), 0)
            ELSE COALESCE(p.dias_mora, 0)
        END AS dias_atraso,

        CASE
            WHEN p.estado_pago = 'Pagado' THEN TRUE
            ELSE FALSE
        END AS es_pagado,

        CASE
            WHEN p.estado_pago = 'En mora' THEN TRUE
            ELSE FALSE
        END AS es_en_mora,

        CASE
            WHEN COALESCE(p.saldo_pendiente, 0) > 0 THEN TRUE
            ELSE FALSE
        END AS es_pendiente,

        CASE
            WHEN p.fecha_pago IS NOT NULL
                 AND p.fecha_vencimiento IS NOT NULL
                 AND p.fecha_pago <= p.fecha_vencimiento
                THEN TRUE
            ELSE FALSE
        END AS es_pago_a_tiempo,

        CASE
            WHEN p.fecha_pago IS NOT NULL
                 AND p.fecha_vencimiento IS NOT NULL
                 AND p.fecha_pago > p.fecha_vencimiento
                THEN TRUE
            ELSE FALSE
        END AS es_pago_tarde,

        CASE
            WHEN p.es_credito = TRUE THEN p.monto_total
            ELSE 0
        END AS monto_credito,

        CASE
            WHEN p.es_credito = FALSE THEN p.monto_total
            ELSE 0
        END AS monto_contado,

        CASE
            WHEN p.estado_pago = 'En mora'
                 AND COALESCE(p.saldo_pendiente, 0) > 0
                THEN p.saldo_pendiente
            ELSE 0
        END AS monto_vencido,

        1 AS pago_count

    FROM {{ ref('stg_pagos') }} p
    INNER JOIN {{ ref('stg_ventas') }} v
        ON p.venta_id = v.venta_id

)

SELECT *
FROM base