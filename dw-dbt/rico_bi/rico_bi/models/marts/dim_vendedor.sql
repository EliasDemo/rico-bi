{{ config(materialized='table', schema='marts') }}

SELECT
    vendedor_id AS vendedor_key,
    vendedor_id,
    codigo,
    nombre_vendedor,
    zona,
    cargo,
    fecha_ingreso,
    telefono,
    email,
    activo
FROM {{ ref('stg_vendedores') }}
