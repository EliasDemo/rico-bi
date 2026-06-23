-- =====================================================
-- 04_cargar_dimensiones.sql
-- CARGA DE DIMENSIONES DEL DATA WAREHOUSE: dw_rico
-- Fuente: rico_oltp
-- Destino: dw_rico
-- Proyecto BI - Corporación Rico S.A.C.
-- =====================================================

USE dw_rico;

-- =====================================================
-- LIMPIEZA DE DIMENSIONES
-- Como todavía no cargamos hechos, podemos limpiar dimensiones.
-- =====================================================

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE DTIEMPO;
TRUNCATE TABLE DCLIENTE;
TRUNCATE TABLE DPRODUCTO;
TRUNCATE TABLE DVENDEDOR;
TRUNCATE TABLE DALMACEN;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- 01. CARGA DIMENSIÓN CLIENTE
-- Fuente: rico_oltp.clientes
-- =====================================================

INSERT INTO DCLIENTE (
    cliente_id,
    ruc_dni,
    razon_social,
    tipo_cliente,
    ciudad,
    provincia,
    departamento,
    fecha_registro,
    activo
)
SELECT
    c.cliente_id,
    c.ruc_dni,
    c.razon_social,
    c.tipo_cliente,
    c.ciudad,
    c.provincia,
    c.departamento,
    c.fecha_registro,
    c.activo
FROM rico_oltp.clientes c;

-- =====================================================
-- 02. CARGA DIMENSIÓN PRODUCTO
-- Fuente: rico_oltp.productos
-- =====================================================

INSERT INTO DPRODUCTO (
    producto_id,
    codigo,
    nombre_producto,
    subcategoria,
    categoria,
    clase_nombre,
    unidad_medida,
    precio_base,
    precio_compra,
    precio_venta_min,
    fraccionable,
    stock_actual,
    stock_minimo,
    activo
)
SELECT
    p.producto_id,
    p.codigo,
    p.nombre_producto,
    p.subcategoria,
    p.categoria,
    p.clase_nombre,
    p.unidad_medida,
    p.precio_base,
    p.precio_compra,
    p.precio_venta_min,
    p.fraccionable,
    p.stock_actual,
    p.stock_minimo,
    p.activo
FROM rico_oltp.productos p;

-- =====================================================
-- 03. CARGA DIMENSIÓN VENDEDOR
-- Fuente: rico_oltp.vendedores
-- Nota: en OLTP el campo se llama nombre, no nombre_vendedor.
-- =====================================================

INSERT INTO DVENDEDOR (
    vendedor_id,
    nombre_vendedor,
    zona,
    fecha_ingreso,
    activo
)
SELECT
    v.vendedor_id,
    v.nombre AS nombre_vendedor,
    v.zona,
    v.fecha_ingreso,
    CASE
        WHEN v.estado = 'Activo' THEN 1
        ELSE 0
    END AS activo
FROM rico_oltp.vendedores v;

-- =====================================================
-- 04. CARGA DIMENSIÓN ALMACÉN
-- Fuente: rico_oltp.almacenes
-- Nota: en OLTP el campo se llama nombre, no nombre_almacen.
-- Nota: OLTP no tiene provincia ni activo en almacenes.
-- =====================================================

INSERT INTO DALMACEN (
    almacen_id,
    nombre_almacen,
    ciudad,
    provincia,
    departamento,
    direccion,
    activo
)
SELECT
    a.almacen_id,
    a.nombre AS nombre_almacen,
    a.ciudad,
    NULL AS provincia,
    a.departamento,
    a.direccion,
    1 AS activo
FROM rico_oltp.almacenes a;

-- =====================================================
-- 05. CARGA DIMENSIÓN TIEMPO
-- Fuente: fechas de ventas y pagos
-- =====================================================

INSERT INTO DTIEMPO (
    fecha,
    anio,
    trimestre,
    mes,
    nombre_mes,
    dia,
    dia_semana,
    nombre_dia,
    semana_anio
)
SELECT DISTINCT
    fechas.fecha,
    YEAR(fechas.fecha) AS anio,
    QUARTER(fechas.fecha) AS trimestre,
    MONTH(fechas.fecha) AS mes,
    CASE MONTH(fechas.fecha)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS nombre_mes,
    DAY(fechas.fecha) AS dia,
    DAYOFWEEK(fechas.fecha) AS dia_semana,
    CASE DAYOFWEEK(fechas.fecha)
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Lunes'
        WHEN 3 THEN 'Martes'
        WHEN 4 THEN 'Miércoles'
        WHEN 5 THEN 'Jueves'
        WHEN 6 THEN 'Viernes'
        WHEN 7 THEN 'Sábado'
    END AS nombre_dia,
    WEEK(fechas.fecha, 3) AS semana_anio
FROM (
    SELECT fecha_venta AS fecha
    FROM rico_oltp.ventas
    WHERE fecha_venta IS NOT NULL

    UNION

    SELECT fecha_emision AS fecha
    FROM rico_oltp.pagos
    WHERE fecha_emision IS NOT NULL

    UNION

    SELECT fecha_vencimiento AS fecha
    FROM rico_oltp.pagos
    WHERE fecha_vencimiento IS NOT NULL

    UNION

    SELECT fecha_pago AS fecha
    FROM rico_oltp.pagos
    WHERE fecha_pago IS NOT NULL
) fechas;

-- =====================================================
-- 06. VALIDACIÓN GENERAL DE CARGA DE DIMENSIONES
-- =====================================================

SELECT 'DTIEMPO' AS tabla, COUNT(*) AS total FROM DTIEMPO
UNION ALL
SELECT 'DCLIENTE', COUNT(*) FROM DCLIENTE
UNION ALL
SELECT 'DPRODUCTO', COUNT(*) FROM DPRODUCTO
UNION ALL
SELECT 'DVENDEDOR', COUNT(*) FROM DVENDEDOR
UNION ALL
SELECT 'DALMACEN', COUNT(*) FROM DALMACEN;

-- =====================================================
-- 07. VALIDACIÓN CONTRA ORIGEN
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
-- 08. VALIDACIÓN DE FECHAS
-- =====================================================

SELECT 
    MIN(fecha) AS fecha_minima,
    MAX(fecha) AS fecha_maxima,
    COUNT(*) AS total_fechas
FROM DTIEMPO;