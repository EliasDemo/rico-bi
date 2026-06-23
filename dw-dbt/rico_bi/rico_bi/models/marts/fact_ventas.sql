{{ config(materialized='table', schema='marts') }}

WITH base AS (

    SELECT
        d.detalle_id AS venta_detalle_key,

        TO_CHAR(v.fecha_venta, 'YYYYMMDD')::INT AS tiempo_key,
        v.cliente_id AS cliente_key,
        d.producto_id AS producto_key,
        v.vendedor_id AS vendedor_key,
        v.almacen_id AS almacen_key,

        v.venta_id,
        d.detalle_id,

        v.tipo_doc,
        v.serie,
        v.numero_doc,
        v.estado,
        v.tipo_pago,
        v.zona_entrega,
        v.vehiculo,
        v.chofer,
        v.repartidor,

        v.fecha_venta,

        d.unidades,
        d.kilos,
        d.precio_venta,
        d.costo_unitario,
        d.descuento,
        d.igv_porcentaje,
        d.igv_monto,
        d.subtotal,
        d.total_linea,

        CASE
            WHEN COALESCE(d.kilos, 0) > 0
                THEN d.kilos * d.costo_unitario
            ELSE COALESCE(d.unidades, 0) * d.costo_unitario
        END AS costo_base

    FROM {{ ref('stg_detalle_ventas') }} d
    INNER JOIN {{ ref('stg_ventas') }} v
        ON d.venta_id = v.venta_id

)

SELECT
    venta_detalle_key,

    tiempo_key,
    cliente_key,
    producto_key,
    vendedor_key,
    almacen_key,

    venta_id,
    detalle_id,

    tipo_doc,
    serie,
    numero_doc,
    estado,
    tipo_pago,
    zona_entrega,
    vehiculo,
    chofer,
    repartidor,

    fecha_venta,

    unidades,
    kilos,
    precio_venta,
    costo_unitario,
    descuento,
    igv_porcentaje,
    igv_monto,

    subtotal,
    total_linea,

    -- Métricas claras para Power BI
    subtotal AS venta_neta_sin_igv,
    total_linea AS venta_facturada_con_igv,

    ROUND(costo_base, 2) AS costo_total,

    -- Margen correcto para rentabilidad: venta sin IGV - costo
    ROUND(subtotal - costo_base, 2) AS margen_bruto,

    ROUND(
        CASE
            WHEN subtotal > 0 THEN
                ((subtotal - costo_base) / subtotal) * 100
            ELSE 0
        END,
    2) AS porcentaje_margen,

    -- Métrica de referencia: margen usando venta con IGV
    -- Se conserva para trazabilidad, pero no será el KPI principal de rentabilidad.
    ROUND(total_linea - costo_base, 2) AS margen_bruto_con_igv,

    ROUND(
        CASE
            WHEN total_linea > 0 THEN
                ((total_linea - costo_base) / total_linea) * 100
            ELSE 0
        END,
    2) AS porcentaje_margen_con_igv,

    1 AS venta_count

FROM base