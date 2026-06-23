{{ config(materialized='view', schema='staging') }}

SELECT
    cliente_id,
    ruc_dni,
    razon_social,
    tipo_cliente,
    ciudad,
    provincia,
    departamento,
    telefono,
    fecha_registro,
    activo
FROM {{ source('raw', 'clientes') }}
