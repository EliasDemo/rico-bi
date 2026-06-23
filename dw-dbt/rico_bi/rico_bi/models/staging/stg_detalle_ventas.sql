{{ config(materialized='view', schema='staging') }}

SELECT
    detalle_id,
    venta_id,
    producto_id,
    kilos,
    unidades,
    precio_venta,
    costo_unitario,
    descuento,
    igv_porcentaje,
    igv_monto,
    subtotal,
    total_linea
FROM {{ source('raw', 'detalle_ventas') }}
