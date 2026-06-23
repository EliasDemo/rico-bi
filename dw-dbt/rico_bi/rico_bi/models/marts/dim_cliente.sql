{{ config(materialized='table', schema='marts') }}

SELECT
    cliente_id AS cliente_key,
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
FROM {{ ref('stg_clientes') }}
