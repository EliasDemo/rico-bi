{{ config(materialized='table', schema='marts') }}

SELECT
    almacen_id AS almacen_key,
    almacen_id,
    nombre_almacen,
    ciudad,
    departamento,
    direccion,
    tipo_almacen,
    responsable
FROM {{ ref('stg_almacenes') }}
