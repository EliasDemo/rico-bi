{{ config(materialized='view', schema='staging') }}

SELECT
    producto_id,
    codigo,
    nombre_producto,
    subcategoria,
    categoria,
    clase_nombre,
    unidad_medida,
    precio_base,
    precio_compra,
    precio_venta_min,
    fraccionable,
    stock_actual,
    stock_minimo,
    activo
FROM {{ source('raw', 'productos') }}
