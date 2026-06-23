{{ config(materialized='view', schema='staging') }}

SELECT
    vendedor_id,
    codigo,
    nombre AS nombre_vendedor,
    zona,
    cargo,
    fecha_ingreso,
    telefono,
    email,
    CASE
        WHEN estado = 'Activo' THEN true
        ELSE false
    END AS activo
FROM {{ source('raw', 'vendedores') }}
