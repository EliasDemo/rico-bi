-- =====================================================
-- 02_crear_raw_tables.sql
-- CREACIÓN DE TABLAS RAW EN POSTGRESQL
-- Proyecto BI - Corporación Rico S.A.C.
-- Fuente: MySQL rico_oltp
-- Destino: PostgreSQL rico_dw.raw
-- =====================================================

CREATE SCHEMA IF NOT EXISTS raw;

-- =====================================================
-- LIMPIEZA DE TABLAS RAW
-- =====================================================

DROP TABLE IF EXISTS raw.pagos CASCADE;
DROP TABLE IF EXISTS raw.detalle_ventas CASCADE;
DROP TABLE IF EXISTS raw.ventas CASCADE;
DROP TABLE IF EXISTS raw.productos CASCADE;
DROP TABLE IF EXISTS raw.clientes CASCADE;
DROP TABLE IF EXISTS raw.vendedores CASCADE;
DROP TABLE IF EXISTS raw.almacenes CASCADE;

-- =====================================================
-- TABLA RAW: CLIENTES
-- =====================================================

CREATE TABLE raw.clientes (
    cliente_id INTEGER,
    ruc_dni VARCHAR(20),
    razon_social VARCHAR(150),
    tipo_cliente VARCHAR(50),
    ciudad VARCHAR(80),
    provincia VARCHAR(80),
    departamento VARCHAR(80),
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_registro DATE,
    activo BOOLEAN
);

-- =====================================================
-- TABLA RAW: PRODUCTOS
-- =====================================================

CREATE TABLE raw.productos (
    producto_id INTEGER,
    codigo VARCHAR(30),
    nombre_producto VARCHAR(150),
    subcategoria VARCHAR(80),
    categoria VARCHAR(80),
    clase_nombre VARCHAR(80),
    unidad_medida VARCHAR(20),
    precio_base NUMERIC(12,2),
    precio_compra NUMERIC(12,2),
    precio_venta_min NUMERIC(12,2),
    fraccionable BOOLEAN,
    stock_actual NUMERIC(12,2),
    stock_minimo NUMERIC(12,2),
    activo BOOLEAN
);

-- =====================================================
-- TABLA RAW: VENDEDORES
-- =====================================================

CREATE TABLE raw.vendedores (
    vendedor_id INTEGER,
    codigo INTEGER,
    nombre VARCHAR(100),
    zona VARCHAR(60),
    cargo VARCHAR(50),
    fecha_ingreso DATE,
    telefono VARCHAR(15),
    email VARCHAR(100),
    estado VARCHAR(10)
);

-- =====================================================
-- TABLA RAW: ALMACENES
-- =====================================================

CREATE TABLE raw.almacenes (
    almacen_id VARCHAR(5),
    nombre VARCHAR(100),
    ciudad VARCHAR(80),
    departamento VARCHAR(80),
    direccion VARCHAR(200),
    tipo_almacen VARCHAR(50),
    responsable VARCHAR(100)
);

-- =====================================================
-- TABLA RAW: VENTAS
-- =====================================================

CREATE TABLE raw.ventas (
    venta_id INTEGER,
    fecha_venta DATE,
    cliente_id INTEGER,
    vendedor_id INTEGER,
    almacen_id VARCHAR(5),
    tipo_doc VARCHAR(30),
    serie VARCHAR(20),
    numero_doc VARCHAR(30),
    estado VARCHAR(40),
    tipo_pago VARCHAR(50),
    zona_entrega VARCHAR(100),
    vehiculo VARCHAR(80),
    chofer VARCHAR(120),
    repartidor VARCHAR(120),
    observaciones TEXT,
    created_at TIMESTAMP
);

-- =====================================================
-- TABLA RAW: DETALLE_VENTAS
-- =====================================================

CREATE TABLE raw.detalle_ventas (
    detalle_id INTEGER,
    venta_id INTEGER,
    producto_id INTEGER,
    kilos NUMERIC(12,2),
    unidades NUMERIC(12,2),
    precio_venta NUMERIC(12,2),
    costo_unitario NUMERIC(12,2),
    descuento NUMERIC(12,2),
    igv_porcentaje NUMERIC(6,2),
    igv_monto NUMERIC(12,2),
    subtotal NUMERIC(12,2),
    total_linea NUMERIC(12,2)
);

-- =====================================================
-- TABLA RAW: PAGOS
-- =====================================================

CREATE TABLE raw.pagos (
    pago_id INTEGER,
    venta_id INTEGER,
    tipo_pago VARCHAR(50),
    plazo_dias INTEGER,
    fecha_emision DATE,
    fecha_vencimiento DATE,
    fecha_pago DATE,
    monto_total NUMERIC(12,2),
    monto_pagado NUMERIC(12,2),
    saldo_pendiente NUMERIC(12,2),
    estado_pago VARCHAR(50),
    dias_mora INTEGER,
    es_credito BOOLEAN
);

-- =====================================================
-- VALIDACIÓN DE TABLAS CREADAS
-- =====================================================

SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'raw'
ORDER BY table_name;

-- =====================================================
-- VALIDACIÓN DE COLUMNAS POR TABLA
-- =====================================================

SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND column_name IN ('activo', 'fraccionable', 'es_credito')
ORDER BY table_name, column_name;

SELECT 
    table_name,
    COUNT(*) AS total_columnas
FROM information_schema.columns
WHERE table_schema = 'raw'
GROUP BY table_name
ORDER BY table_name;