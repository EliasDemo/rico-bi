{{ config(materialized='view', schema='staging') }}

SELECT
    pago_id,
    venta_id,
    tipo_pago,
    plazo_dias,
    fecha_emision,
    fecha_vencimiento,
    fecha_pago,
    monto_total,
    monto_pagado,
    saldo_pendiente,
    estado_pago,
    dias_mora,
    es_credito
FROM {{ source('raw', 'pagos') }}
