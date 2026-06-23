{{ config(materialized='view', schema='staging') }}

SELECT
    venta_id,
    fecha_venta,
    cliente_id,
    vendedor_id,
    almacen_id,
    tipo_doc,
    serie,
    numero_doc,
    estado,
    tipo_pago,
    zona_entrega,
    vehiculo,
    chofer,
    repartidor,
    created_at
FROM {{ source('raw', 'ventas') }}
