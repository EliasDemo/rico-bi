USE rico_oltp;

-- =====================================================
-- 01. CONTEO GENERAL DE TABLAS
-- =====================================================
SELECT 'clientes' AS tabla, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'productos', COUNT(*) FROM productos
UNION ALL
SELECT 'vendedores', COUNT(*) FROM vendedores
UNION ALL
SELECT 'almacenes', COUNT(*) FROM almacenes
UNION ALL
SELECT 'ventas', COUNT(*) FROM ventas
UNION ALL
SELECT 'detalle_ventas', COUNT(*) FROM detalle_ventas
UNION ALL
SELECT 'pagos', COUNT(*) FROM pagos;

-- =====================================================
-- 02. VENTAS SIN DETALLE
-- Esperado: sin filas
-- =====================================================
SELECT 
    v.venta_id,
    v.fecha_venta,
    v.numero_doc
FROM ventas v
LEFT JOIN detalle_ventas dv 
    ON v.venta_id = dv.venta_id
WHERE dv.detalle_id IS NULL;

-- =====================================================
-- 03. DETALLES SIN VENTA
-- Esperado: sin filas
-- =====================================================
SELECT 
    dv.detalle_id,
    dv.venta_id
FROM detalle_ventas dv
LEFT JOIN ventas v 
    ON dv.venta_id = v.venta_id
WHERE v.venta_id IS NULL;

-- =====================================================
-- 04. PAGOS SIN VENTA
-- Esperado: sin filas
-- =====================================================
SELECT 
    p.pago_id,
    p.venta_id
FROM pagos p
LEFT JOIN ventas v 
    ON p.venta_id = v.venta_id
WHERE v.venta_id IS NULL;

-- =====================================================
-- 05. DETALLES SIN PRODUCTO
-- Esperado: sin filas
-- =====================================================
SELECT 
    dv.detalle_id,
    dv.producto_id
FROM detalle_ventas dv
LEFT JOIN productos pr 
    ON dv.producto_id = pr.producto_id
WHERE pr.producto_id IS NULL;

-- =====================================================
-- 06. VENTAS SIN CLIENTE
-- Esperado: sin filas
-- =====================================================
SELECT 
    v.venta_id,
    v.cliente_id
FROM ventas v
LEFT JOIN clientes c 
    ON v.cliente_id = c.cliente_id
WHERE c.cliente_id IS NULL;

-- =====================================================
-- 07. VENTAS SIN VENDEDOR
-- Esperado: sin filas
-- =====================================================
SELECT 
    v.venta_id,
    v.vendedor_id
FROM ventas v
LEFT JOIN vendedores ve 
    ON v.vendedor_id = ve.vendedor_id
WHERE ve.vendedor_id IS NULL;

-- =====================================================
-- 08. VENTAS SIN ALMACÉN
-- Esperado: sin filas
-- =====================================================
SELECT 
    v.venta_id,
    v.almacen_id
FROM ventas v
LEFT JOIN almacenes a 
    ON v.almacen_id = a.almacen_id
WHERE a.almacen_id IS NULL;

-- =====================================================
-- 09. TOTAL DE VENTA CONTRA DETALLE
-- Se permite diferencia menor o igual a 0.05 por redondeo
-- Esperado: sin filas o pocas diferencias mayores
-- =====================================================
SELECT 
    v.venta_id,
    v.numero_doc,
    ROUND(v.total, 2) AS total_venta,
    ROUND(SUM(dv.total_linea), 2) AS total_detalle,
    ROUND(ABS(v.total - SUM(dv.total_linea)), 2) AS diferencia
FROM ventas v
INNER JOIN detalle_ventas dv 
    ON v.venta_id = dv.venta_id
GROUP BY 
    v.venta_id,
    v.numero_doc,
    v.total
HAVING ROUND(ABS(v.total - SUM(dv.total_linea)), 2) > 0.05;

-- =====================================================
-- 10. MONTO DE PAGO CONTRA TOTAL DE VENTA
-- Esperado: sin filas
-- =====================================================
SELECT 
    v.venta_id,
    v.numero_doc,
    ROUND(v.total, 2) AS total_venta,
    ROUND(p.monto_total, 2) AS monto_pago
FROM ventas v
INNER JOIN pagos p 
    ON v.venta_id = p.venta_id
WHERE ROUND(v.total, 2) <> ROUND(p.monto_total, 2);

-- =====================================================
-- 11. IMPORTES NEGATIVOS EN DETALLE
-- Esperado: sin filas
-- =====================================================
SELECT 
    detalle_id,
    venta_id,
    producto_id,
    kilos,
    unidades,
    precio_venta,
    costo_unitario,
    descuento,
    total_linea
FROM detalle_ventas
WHERE kilos < 0
   OR unidades < 0
   OR precio_venta < 0
   OR costo_unitario < 0
   OR descuento < 0
   OR total_linea < 0;

-- =====================================================
-- 12. PAGOS CON MONTOS NEGATIVOS
-- Esperado: sin filas
-- =====================================================
SELECT 
    pago_id,
    venta_id,
    monto_total,
    monto_pagado,
    saldo_pendiente,
    dias_mora
FROM pagos
WHERE monto_total < 0
   OR monto_pagado < 0
   OR saldo_pendiente < 0
   OR dias_mora < 0;

-- =====================================================
-- 13. FECHAS DE PAGO ANTES DE LA VENTA
-- Esperado: sin filas
-- =====================================================
SELECT
    p.pago_id,
    p.venta_id,
    v.fecha_venta,
    p.fecha_pago
FROM pagos p
INNER JOIN ventas v
    ON p.venta_id = v.venta_id
WHERE p.fecha_pago IS NOT NULL
  AND p.fecha_pago < v.fecha_venta;