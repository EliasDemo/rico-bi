{{ config(materialized='view', schema='staging') }}

SELECT
    almacen_id,
    nombre AS nombre_almacen,
    ciudad,
    departamento,
    direccion,
    tipo_almacen,
    responsable
FROM {{ source('raw', 'almacenes') }}
