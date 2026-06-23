{{ config(materialized='table', schema='marts') }}

SELECT
    producto_id AS producto_key,
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
FROM {{ ref('stg_productos') }}
