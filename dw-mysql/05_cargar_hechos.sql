-- =====================================================
-- 05_cargar_hechos.sql
-- CARGA DE TABLAS DE HECHOS DEL DATA WAREHOUSE: dw_rico
-- Fuente: rico_oltp
-- Destino: dw_rico
-- Proyecto BI - Corporación Rico S.A.C.
-- =====================================================

USE dw_rico;

-- =====================================================
-- LIMPIEZA DE TABLAS DE HECHOS
-- =====================================================

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE HVENTA;
TRUNCATE TABLE HPAGO;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- 01. CARGA TABLA DE HECHOS HVENTA
-- Grano: una fila por línea de detalle de venta
-- Fuente:
--   rico_oltp.ventas
--   rico_oltp.detalle_ventas
-- =====================================================

INSERT INTO HVENTA (
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
    fecha_entrega,

    unidades,
    kilos,
    precio_venta,
    costo_unitario,
    descuento,
    igv_porcentaje,
    igv_monto,
    subtotal,
    total_linea,

    costo_total,
    margen_bruto,
    porcentaje_margen,

    venta_count
)
SELECT
    dt.tiempo_key,
    dc.cliente_key,
    dp.producto_key,
    dvend.vendedor_key,
    da.almacen_key,

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
    NULL AS fecha_entrega,

    d.unidades,
    d.kilos,
    d.precio_venta,
    d.costo_unitario,
    d.descuento,
    d.igv_porcentaje,
    d.igv_monto,
    d.subtotal,
    d.total_linea,

    -- Costo total estimado.
    -- Si hay kilos, se usa kilos * costo_unitario.
    -- Si no hay kilos, se usa unidades * costo_unitario.
    ROUND(
        CASE 
            WHEN d.kilos IS NOT NULL AND d.kilos > 0 
                THEN d.kilos * d.costo_unitario
            ELSE d.unidades * d.costo_unitario
        END, 
    2) AS costo_total,

    -- Margen bruto = venta neta de la línea - costo total
    ROUND(
        d.total_linea - 
        CASE 
            WHEN d.kilos IS NOT NULL AND d.kilos > 0 
                THEN d.kilos * d.costo_unitario
            ELSE d.unidades * d.costo_unitario
        END,
    2) AS margen_bruto,

    -- Porcentaje de margen
    ROUND(
        CASE 
            WHEN d.total_linea > 0 THEN
                (
                    (
                        d.total_linea - 
                        CASE 
                            WHEN d.kilos IS NOT NULL AND d.kilos > 0 
                                THEN d.kilos * d.costo_unitario
                            ELSE d.unidades * d.costo_unitario
                        END
                    ) / d.total_linea
                ) * 100
            ELSE 0
        END,
    2) AS porcentaje_margen,

    1 AS venta_count

FROM rico_oltp.detalle_ventas d
INNER JOIN rico_oltp.ventas v
    ON d.venta_id = v.venta_id

INNER JOIN DTIEMPO dt
    ON dt.fecha = v.fecha_venta

INNER JOIN DCLIENTE dc
    ON dc.cliente_id = v.cliente_id

INNER JOIN DPRODUCTO dp
    ON dp.producto_id = d.producto_id

INNER JOIN DVENDEDOR dvend
    ON dvend.vendedor_id = v.vendedor_id

INNER JOIN DALMACEN da
    ON da.almacen_id = v.almacen_id;

-- =====================================================
-- 02. CARGA TABLA DE HECHOS HPAGO
-- Grano: una fila por pago asociado a una venta
-- Fuente:
--   rico_oltp.pagos
--   rico_oltp.ventas
-- =====================================================

INSERT INTO HPAGO (
    tiempo_key,
    cliente_key,
    vendedor_key,
    almacen_key,

    pago_id,
    venta_id,

    tipo_doc,
    serie,
    numero_doc,
    tipo_pago,
    estado_pago,

    fecha_emision,
    fecha_vencimiento,
    fecha_pago,

    plazo_dias,
    monto_total,
    monto_pagado,
    saldo_pendiente,
    dias_mora,
    es_credito,

    pago_count
)
SELECT
    dt.tiempo_key,
    dc.cliente_key,
    dvend.vendedor_key,
    da.almacen_key,

    p.pago_id,
    p.venta_id,

    v.tipo_doc,
    v.serie,
    v.numero_doc,
    p.tipo_pago,
    p.estado_pago,

    p.fecha_emision,
    p.fecha_vencimiento,
    p.fecha_pago,

    p.plazo_dias,
    p.monto_total,
    p.monto_pagado,
    p.saldo_pendiente,
    p.dias_mora,
    p.es_credito,

    1 AS pago_count

FROM rico_oltp.pagos p
INNER JOIN rico_oltp.ventas v
    ON p.venta_id = v.venta_id

INNER JOIN DTIEMPO dt
    ON dt.fecha = p.fecha_emision

INNER JOIN DCLIENTE dc
    ON dc.cliente_id = v.cliente_id

INNER JOIN DVENDEDOR dvend
    ON dvend.vendedor_id = v.vendedor_id

INNER JOIN DALMACEN da
    ON da.almacen_id = v.almacen_id;

-- =====================================================
-- 03. VALIDACIÓN GENERAL DE CARGA DE HECHOS
-- =====================================================

SELECT 'HVENTA' AS tabla, COUNT(*) AS total FROM HVENTA
UNION ALL
SELECT 'HPAGO', COUNT(*) FROM HPAGO;

-- =====================================================
-- 04. VALIDACIÓN CONTRA ORIGEN
-- =====================================================

SELECT 
    'detalle_ventas_origen' AS tabla,
    COUNT(*) AS total
FROM rico_oltp.detalle_ventas
UNION ALL
SELECT 
    'HVENTA_destino',
    COUNT(*)
FROM dw_rico.HVENTA;

SELECT 
    'pagos_origen' AS tabla,
    COUNT(*) AS total
FROM rico_oltp.pagos
UNION ALL
SELECT 
    'HPAGO_destino',
    COUNT(*)
FROM dw_rico.HPAGO;

-- =====================================================
-- 05. VALIDACIÓN DE MÉTRICAS PRINCIPALES
-- =====================================================

SELECT
    ROUND(SUM(total_linea), 2) AS ventas_totales,
    ROUND(SUM(costo_total), 2) AS costos_totales,
    ROUND(SUM(margen_bruto), 2) AS margen_bruto_total,
    ROUND(AVG(porcentaje_margen), 2) AS margen_promedio_porcentaje,
    ROUND(SUM(kilos), 2) AS kilos_totales,
    ROUND(SUM(unidades), 2) AS unidades_totales
FROM HVENTA;

SELECT
    ROUND(SUM(monto_total), 2) AS monto_total,
    ROUND(SUM(monto_pagado), 2) AS monto_pagado,
    ROUND(SUM(saldo_pendiente), 2) AS saldo_pendiente,
    ROUND(AVG(dias_mora), 2) AS dias_mora_promedio
FROM HPAGO;

-- =====================================================
-- 06. VALIDAR NULOS EN CLAVES DEL HECHO
-- Esperado: 0 en todos
-- =====================================================

SELECT
    SUM(CASE WHEN tiempo_key IS NULL THEN 1 ELSE 0 END) AS nulos_tiempo,
    SUM(CASE WHEN cliente_key IS NULL THEN 1 ELSE 0 END) AS nulos_cliente,
    SUM(CASE WHEN producto_key IS NULL THEN 1 ELSE 0 END) AS nulos_producto,
    SUM(CASE WHEN vendedor_key IS NULL THEN 1 ELSE 0 END) AS nulos_vendedor,
    SUM(CASE WHEN almacen_key IS NULL THEN 1 ELSE 0 END) AS nulos_almacen
FROM HVENTA;

SELECT
    SUM(CASE WHEN tiempo_key IS NULL THEN 1 ELSE 0 END) AS nulos_tiempo,
    SUM(CASE WHEN cliente_key IS NULL THEN 1 ELSE 0 END) AS nulos_cliente,
    SUM(CASE WHEN vendedor_key IS NULL THEN 1 ELSE 0 END) AS nulos_vendedor,
    SUM(CASE WHEN almacen_key IS NULL THEN 1 ELSE 0 END) AS nulos_almacen
FROM HPAGO;