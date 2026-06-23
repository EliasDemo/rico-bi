-- =====================================================
-- 06_validar_dw_rico.sql
-- VALIDACIÓN DEL DATA WAREHOUSE: dw_rico
-- Proyecto BI - Corporación Rico S.A.C.
-- =====================================================

USE dw_rico;

-- =====================================================
-- 01. CONTEO GENERAL DEL DATA WAREHOUSE
-- =====================================================

SELECT 'DTIEMPO' AS tabla, COUNT(*) AS total FROM DTIEMPO
UNION ALL
SELECT 'DCLIENTE', COUNT(*) FROM DCLIENTE
UNION ALL
SELECT 'DPRODUCTO', COUNT(*) FROM DPRODUCTO
UNION ALL
SELECT 'DVENDEDOR', COUNT(*) FROM DVENDEDOR
UNION ALL
SELECT 'DALMACEN', COUNT(*) FROM DALMACEN
UNION ALL
SELECT 'HVENTA', COUNT(*) FROM HVENTA
UNION ALL
SELECT 'HPAGO', COUNT(*) FROM HPAGO;

-- =====================================================
-- 02. VALIDACIÓN DE HECHOS CONTRA ORIGEN
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
-- 03. VALIDACIÓN DE DIMENSIONES CONTRA ORIGEN
-- =====================================================

SELECT 
    'clientes_origen' AS tabla,
    COUNT(*) AS total
FROM rico_oltp.clientes
UNION ALL
SELECT 
    'DCLIENTE_destino',
    COUNT(*)
FROM dw_rico.DCLIENTE;

SELECT 
    'productos_origen' AS tabla,
    COUNT(*) AS total
FROM rico_oltp.productos
UNION ALL
SELECT 
    'DPRODUCTO_destino',
    COUNT(*)
FROM dw_rico.DPRODUCTO;

SELECT 
    'vendedores_origen' AS tabla,
    COUNT(*) AS total
FROM rico_oltp.vendedores
UNION ALL
SELECT 
    'DVENDEDOR_destino',
    COUNT(*)
FROM dw_rico.DVENDEDOR;

SELECT 
    'almacenes_origen' AS tabla,
    COUNT(*) AS total
FROM rico_oltp.almacenes
UNION ALL
SELECT 
    'DALMACEN_destino',
    COUNT(*)
FROM dw_rico.DALMACEN;

-- =====================================================
-- 04. VALIDAR DUPLICADOS EN HECHOS
-- Esperado: sin filas
-- =====================================================

SELECT 
    detalle_id,
    COUNT(*) AS repeticiones
FROM HVENTA
GROUP BY detalle_id
HAVING COUNT(*) > 1;

SELECT 
    pago_id,
    COUNT(*) AS repeticiones
FROM HPAGO
GROUP BY pago_id
HAVING COUNT(*) > 1;

-- =====================================================
-- 05. VALIDAR CLAVES NULAS EN HVENTA
-- Esperado: 0 en todos
-- =====================================================

SELECT
    SUM(CASE WHEN tiempo_key IS NULL THEN 1 ELSE 0 END) AS nulos_tiempo,
    SUM(CASE WHEN cliente_key IS NULL THEN 1 ELSE 0 END) AS nulos_cliente,
    SUM(CASE WHEN producto_key IS NULL THEN 1 ELSE 0 END) AS nulos_producto,
    SUM(CASE WHEN vendedor_key IS NULL THEN 1 ELSE 0 END) AS nulos_vendedor,
    SUM(CASE WHEN almacen_key IS NULL THEN 1 ELSE 0 END) AS nulos_almacen
FROM HVENTA;

-- =====================================================
-- 06. VALIDAR CLAVES NULAS EN HPAGO
-- Esperado: 0 en todos
-- =====================================================

SELECT
    SUM(CASE WHEN tiempo_key IS NULL THEN 1 ELSE 0 END) AS nulos_tiempo,
    SUM(CASE WHEN cliente_key IS NULL THEN 1 ELSE 0 END) AS nulos_cliente,
    SUM(CASE WHEN vendedor_key IS NULL THEN 1 ELSE 0 END) AS nulos_vendedor,
    SUM(CASE WHEN almacen_key IS NULL THEN 1 ELSE 0 END) AS nulos_almacen
FROM HPAGO;

-- =====================================================
-- 07. VALIDAR INTEGRIDAD ENTRE HVENTA Y DIMENSIONES
-- Esperado: 0 en todos
-- =====================================================

SELECT 
    SUM(CASE WHEN dt.tiempo_key IS NULL THEN 1 ELSE 0 END) AS sin_tiempo,
    SUM(CASE WHEN dc.cliente_key IS NULL THEN 1 ELSE 0 END) AS sin_cliente,
    SUM(CASE WHEN dp.producto_key IS NULL THEN 1 ELSE 0 END) AS sin_producto,
    SUM(CASE WHEN dv.vendedor_key IS NULL THEN 1 ELSE 0 END) AS sin_vendedor,
    SUM(CASE WHEN da.almacen_key IS NULL THEN 1 ELSE 0 END) AS sin_almacen
FROM HVENTA hv
LEFT JOIN DTIEMPO dt ON hv.tiempo_key = dt.tiempo_key
LEFT JOIN DCLIENTE dc ON hv.cliente_key = dc.cliente_key
LEFT JOIN DPRODUCTO dp ON hv.producto_key = dp.producto_key
LEFT JOIN DVENDEDOR dv ON hv.vendedor_key = dv.vendedor_key
LEFT JOIN DALMACEN da ON hv.almacen_key = da.almacen_key;

-- =====================================================
-- 08. VALIDAR INTEGRIDAD ENTRE HPAGO Y DIMENSIONES
-- Esperado: 0 en todos
-- =====================================================

SELECT 
    SUM(CASE WHEN dt.tiempo_key IS NULL THEN 1 ELSE 0 END) AS sin_tiempo,
    SUM(CASE WHEN dc.cliente_key IS NULL THEN 1 ELSE 0 END) AS sin_cliente,
    SUM(CASE WHEN dv.vendedor_key IS NULL THEN 1 ELSE 0 END) AS sin_vendedor,
    SUM(CASE WHEN da.almacen_key IS NULL THEN 1 ELSE 0 END) AS sin_almacen
FROM HPAGO hp
LEFT JOIN DTIEMPO dt ON hp.tiempo_key = dt.tiempo_key
LEFT JOIN DCLIENTE dc ON hp.cliente_key = dc.cliente_key
LEFT JOIN DVENDEDOR dv ON hp.vendedor_key = dv.vendedor_key
LEFT JOIN DALMACEN da ON hp.almacen_key = da.almacen_key;

-- =====================================================
-- 09. VALIDACIÓN DE VENTAS DW VS OLTP
-- Se permite diferencia pequeña por redondeo
-- =====================================================

SELECT
    ROUND((SELECT SUM(total_linea) FROM rico_oltp.detalle_ventas), 2) AS ventas_oltp,
    ROUND((SELECT SUM(total_linea) FROM dw_rico.HVENTA), 2) AS ventas_dw,
    ROUND(
        ABS(
            (SELECT SUM(total_linea) FROM rico_oltp.detalle_ventas)
            -
            (SELECT SUM(total_linea) FROM dw_rico.HVENTA)
        ), 
    2) AS diferencia;

-- =====================================================
-- 10. VALIDACIÓN DE PAGOS DW VS OLTP
-- =====================================================

SELECT
    ROUND((SELECT SUM(monto_total) FROM rico_oltp.pagos), 2) AS pagos_oltp,
    ROUND((SELECT SUM(monto_total) FROM dw_rico.HPAGO), 2) AS pagos_dw,
    ROUND(
        ABS(
            (SELECT SUM(monto_total) FROM rico_oltp.pagos)
            -
            (SELECT SUM(monto_total) FROM dw_rico.HPAGO)
        ), 
    2) AS diferencia;

-- =====================================================
-- 11. INDICADORES GENERALES DE VENTAS
-- =====================================================

SELECT
    ROUND(SUM(total_linea), 2) AS ventas_totales,
    ROUND(SUM(costo_total), 2) AS costos_totales,
    ROUND(SUM(margen_bruto), 2) AS margen_bruto_total,
    ROUND((SUM(margen_bruto) / SUM(total_linea)) * 100, 2) AS porcentaje_margen_global,
    ROUND(AVG(porcentaje_margen), 2) AS porcentaje_margen_promedio,
    ROUND(SUM(kilos), 2) AS kilos_totales,
    ROUND(SUM(unidades), 2) AS unidades_totales,
    COUNT(*) AS lineas_venta,
    COUNT(DISTINCT venta_id) AS total_ventas
FROM HVENTA;

-- =====================================================
-- 12. INDICADORES GENERALES DE PAGOS
-- =====================================================

SELECT
    ROUND(SUM(monto_total), 2) AS monto_total,
    ROUND(SUM(monto_pagado), 2) AS monto_pagado,
    ROUND(SUM(saldo_pendiente), 2) AS saldo_pendiente,
    ROUND((SUM(monto_pagado) / SUM(monto_total)) * 100, 2) AS porcentaje_cobrado,
    ROUND((SUM(saldo_pendiente) / SUM(monto_total)) * 100, 2) AS porcentaje_pendiente,
    ROUND(AVG(dias_mora), 2) AS dias_mora_promedio,
    COUNT(*) AS total_pagos
FROM HPAGO;

-- =====================================================
-- 13. TOP 10 PRODUCTOS POR VENTA
-- =====================================================

SELECT
    dp.nombre_producto,
    dp.categoria,
    ROUND(SUM(hv.total_linea), 2) AS ventas_totales,
    ROUND(SUM(hv.margen_bruto), 2) AS margen_bruto,
    ROUND(SUM(hv.kilos), 2) AS kilos_vendidos,
    ROUND(SUM(hv.unidades), 2) AS unidades_vendidas
FROM HVENTA hv
INNER JOIN DPRODUCTO dp
    ON hv.producto_key = dp.producto_key
GROUP BY 
    dp.nombre_producto,
    dp.categoria
ORDER BY ventas_totales DESC
LIMIT 10;

-- =====================================================
-- 14. TOP 10 CLIENTES POR VENTA
-- =====================================================

SELECT
    dc.razon_social,
    dc.tipo_cliente,
    dc.ciudad,
    ROUND(SUM(hv.total_linea), 2) AS ventas_totales,
    COUNT(DISTINCT hv.venta_id) AS cantidad_ventas
FROM HVENTA hv
INNER JOIN DCLIENTE dc
    ON hv.cliente_key = dc.cliente_key
GROUP BY 
    dc.razon_social,
    dc.tipo_cliente,
    dc.ciudad
ORDER BY ventas_totales DESC
LIMIT 10;

-- =====================================================
-- 15. VENTAS POR VENDEDOR
-- =====================================================

SELECT
    dv.nombre_vendedor,
    dv.zona,
    ROUND(SUM(hv.total_linea), 2) AS ventas_totales,
    ROUND(SUM(hv.margen_bruto), 2) AS margen_bruto,
    COUNT(DISTINCT hv.venta_id) AS cantidad_ventas
FROM HVENTA hv
INNER JOIN DVENDEDOR dv
    ON hv.vendedor_key = dv.vendedor_key
GROUP BY 
    dv.nombre_vendedor,
    dv.zona
ORDER BY ventas_totales DESC;

-- =====================================================
-- 16. VENTAS POR ALMACÉN
-- =====================================================

SELECT
    da.nombre_almacen,
    da.ciudad,
    ROUND(SUM(hv.total_linea), 2) AS ventas_totales,
    ROUND(SUM(hv.margen_bruto), 2) AS margen_bruto,
    COUNT(DISTINCT hv.venta_id) AS cantidad_ventas
FROM HVENTA hv
INNER JOIN DALMACEN da
    ON hv.almacen_key = da.almacen_key
GROUP BY 
    da.nombre_almacen,
    da.ciudad
ORDER BY ventas_totales DESC;

-- =====================================================
-- 17. VENTAS POR AÑO Y MES
-- =====================================================

SELECT
    dt.anio,
    dt.mes,
    dt.nombre_mes,
    ROUND(SUM(hv.total_linea), 2) AS ventas_totales,
    ROUND(SUM(hv.margen_bruto), 2) AS margen_bruto,
    COUNT(DISTINCT hv.venta_id) AS cantidad_ventas
FROM HVENTA hv
INNER JOIN DTIEMPO dt
    ON hv.tiempo_key = dt.tiempo_key
GROUP BY 
    dt.anio,
    dt.mes,
    dt.nombre_mes
ORDER BY 
    dt.anio,
    dt.mes;

-- =====================================================
-- 18. COBRANZA POR ESTADO DE PAGO
-- =====================================================

SELECT
    estado_pago,
    COUNT(*) AS cantidad_pagos,
    ROUND(SUM(monto_total), 2) AS monto_total,
    ROUND(SUM(monto_pagado), 2) AS monto_pagado,
    ROUND(SUM(saldo_pendiente), 2) AS saldo_pendiente
FROM HPAGO
GROUP BY estado_pago
ORDER BY monto_total DESC;

-- =====================================================
-- 19. PAGOS AL CRÉDITO VS CONTADO
-- =====================================================

SELECT
    CASE 
        WHEN es_credito = 1 THEN 'Crédito'
        ELSE 'Contado'
    END AS tipo_operacion,
    COUNT(*) AS cantidad_pagos,
    ROUND(SUM(monto_total), 2) AS monto_total,
    ROUND(SUM(monto_pagado), 2) AS monto_pagado,
    ROUND(SUM(saldo_pendiente), 2) AS saldo_pendiente,
    ROUND(AVG(dias_mora), 2) AS dias_mora_promedio
FROM HPAGO
GROUP BY 
    CASE 
        WHEN es_credito = 1 THEN 'Crédito'
        ELSE 'Contado'
    END;