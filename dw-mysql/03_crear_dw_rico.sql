-- =====================================================
-- 03_crear_dw_rico.sql
-- CREACIÓN DEL DATA WAREHOUSE: dw_rico
-- Proyecto BI - Corporación Rico S.A.C.
-- =====================================================

DROP DATABASE IF EXISTS dw_rico;
CREATE DATABASE dw_rico
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE dw_rico;

-- =====================================================
-- DIMENSIÓN TIEMPO
-- =====================================================
CREATE TABLE DTIEMPO (
    tiempo_key INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    anio INT NOT NULL,
    trimestre INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    dia INT NOT NULL,
    dia_semana INT NOT NULL,
    nombre_dia VARCHAR(20) NOT NULL,
    semana_anio INT NOT NULL,

    UNIQUE KEY uk_dtiempo_fecha (fecha)
);

-- =====================================================
-- DIMENSIÓN CLIENTE
-- =====================================================
CREATE TABLE DCLIENTE (
    cliente_key INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    ruc_dni VARCHAR(20),
    razon_social VARCHAR(150) NOT NULL,
    tipo_cliente VARCHAR(50),
    ciudad VARCHAR(80),
    provincia VARCHAR(80),
    departamento VARCHAR(80),
    fecha_registro DATE,
    activo TINYINT(1),

    UNIQUE KEY uk_dcliente_id (cliente_id)
);

-- =====================================================
-- DIMENSIÓN PRODUCTO
-- =====================================================
CREATE TABLE DPRODUCTO (
    producto_key INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    codigo VARCHAR(30),
    nombre_producto VARCHAR(150) NOT NULL,
    subcategoria VARCHAR(80),
    categoria VARCHAR(80),
    clase_nombre VARCHAR(80),
    unidad_medida VARCHAR(20),
    precio_base DECIMAL(12,2),
    precio_compra DECIMAL(12,2),
    precio_venta_min DECIMAL(12,2),
    fraccionable TINYINT(1),
    stock_actual DECIMAL(12,2),
    stock_minimo DECIMAL(12,2),
    activo TINYINT(1),

    UNIQUE KEY uk_dproducto_id (producto_id)
);

-- =====================================================
-- DIMENSIÓN VENDEDOR
-- =====================================================
CREATE TABLE DVENDEDOR (
    vendedor_key INT AUTO_INCREMENT PRIMARY KEY,
    vendedor_id INT NOT NULL,
    nombre_vendedor VARCHAR(120) NOT NULL,
    zona VARCHAR(80),
    fecha_ingreso DATE,
    activo TINYINT(1),

    UNIQUE KEY uk_dvendedor_id (vendedor_id)
);

-- =====================================================
-- DIMENSIÓN ALMACÉN
-- =====================================================
CREATE TABLE DALMACEN (
    almacen_key INT AUTO_INCREMENT PRIMARY KEY,
    almacen_id VARCHAR(5) NOT NULL,
    nombre_almacen VARCHAR(120) NOT NULL,
    ciudad VARCHAR(80),
    provincia VARCHAR(80),
    departamento VARCHAR(80),
    direccion VARCHAR(200),
    activo TINYINT(1),

    UNIQUE KEY uk_dalmacen_id (almacen_id)
);

-- =====================================================
-- TABLA DE HECHOS: VENTAS
-- Grano: una fila por línea de detalle de venta
-- =====================================================
CREATE TABLE HVENTA (
    hventa_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    -- Claves sustitutas del DW
    tiempo_key INT NOT NULL,
    cliente_key INT NOT NULL,
    producto_key INT NOT NULL,
    vendedor_key INT NOT NULL,
    almacen_key INT NOT NULL,

    -- Identificadores de origen
    venta_id INT NOT NULL,
    detalle_id INT NOT NULL,

    -- Datos degenerados del documento
    tipo_doc VARCHAR(30),
    serie VARCHAR(20),
    numero_doc VARCHAR(30),
    estado VARCHAR(40),
    tipo_pago VARCHAR(50),
    zona_entrega VARCHAR(100),
    vehiculo VARCHAR(80),
    chofer VARCHAR(120),
    repartidor VARCHAR(120),

    -- Fechas operativas
    fecha_venta DATE,
    fecha_entrega DATE,

    -- Métricas
    unidades DECIMAL(12,2),
    kilos DECIMAL(12,2),
    precio_venta DECIMAL(12,2),
    costo_unitario DECIMAL(12,2),
    descuento DECIMAL(12,2),
    igv_porcentaje DECIMAL(6,2),
    igv_monto DECIMAL(12,2),
    subtotal DECIMAL(12,2),
    total_linea DECIMAL(12,2),

    costo_total DECIMAL(12,2),
    margen_bruto DECIMAL(12,2),
    porcentaje_margen DECIMAL(8,2),

    -- Medida auxiliar
    venta_count INT DEFAULT 1,

    CONSTRAINT fk_hventa_tiempo
        FOREIGN KEY (tiempo_key) REFERENCES DTIEMPO(tiempo_key),

    CONSTRAINT fk_hventa_cliente
        FOREIGN KEY (cliente_key) REFERENCES DCLIENTE(cliente_key),

    CONSTRAINT fk_hventa_producto
        FOREIGN KEY (producto_key) REFERENCES DPRODUCTO(producto_key),

    CONSTRAINT fk_hventa_vendedor
        FOREIGN KEY (vendedor_key) REFERENCES DVENDEDOR(vendedor_key),

    CONSTRAINT fk_hventa_almacen
        FOREIGN KEY (almacen_key) REFERENCES DALMACEN(almacen_key),

    UNIQUE KEY uk_hventa_detalle_origen (detalle_id)
);

-- =====================================================
-- TABLA DE HECHOS: PAGOS
-- Grano: una fila por pago asociado a una venta
-- =====================================================
CREATE TABLE HPAGO (
    hpago_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    -- Claves sustitutas del DW
    tiempo_key INT NOT NULL,
    cliente_key INT NOT NULL,
    vendedor_key INT NOT NULL,
    almacen_key INT NOT NULL,

    -- Identificadores de origen
    pago_id INT NOT NULL,
    venta_id INT NOT NULL,

    -- Datos de documento
    tipo_doc VARCHAR(30),
    serie VARCHAR(20),
    numero_doc VARCHAR(30),
    tipo_pago VARCHAR(50),
    estado_pago VARCHAR(50),

    -- Fechas
    fecha_emision DATE,
    fecha_vencimiento DATE,
    fecha_pago DATE,

    -- Métricas de cobranza
    plazo_dias INT,
    monto_total DECIMAL(12,2),
    monto_pagado DECIMAL(12,2),
    saldo_pendiente DECIMAL(12,2),
    dias_mora INT,
    es_credito TINYINT(1),

    -- Medida auxiliar
    pago_count INT DEFAULT 1,

    CONSTRAINT fk_hpago_tiempo
        FOREIGN KEY (tiempo_key) REFERENCES DTIEMPO(tiempo_key),

    CONSTRAINT fk_hpago_cliente
        FOREIGN KEY (cliente_key) REFERENCES DCLIENTE(cliente_key),

    CONSTRAINT fk_hpago_vendedor
        FOREIGN KEY (vendedor_key) REFERENCES DVENDEDOR(vendedor_key),

    CONSTRAINT fk_hpago_almacen
        FOREIGN KEY (almacen_key) REFERENCES DALMACEN(almacen_key),

    UNIQUE KEY uk_hpago_origen (pago_id)
);

-- =====================================================
-- ÍNDICES PARA MEJORAR CONSULTAS ANALÍTICAS
-- =====================================================

CREATE INDEX idx_hventa_tiempo ON HVENTA(tiempo_key);
CREATE INDEX idx_hventa_cliente ON HVENTA(cliente_key);
CREATE INDEX idx_hventa_producto ON HVENTA(producto_key);
CREATE INDEX idx_hventa_vendedor ON HVENTA(vendedor_key);
CREATE INDEX idx_hventa_almacen ON HVENTA(almacen_key);
CREATE INDEX idx_hventa_venta_id ON HVENTA(venta_id);

CREATE INDEX idx_hpago_tiempo ON HPAGO(tiempo_key);
CREATE INDEX idx_hpago_cliente ON HPAGO(cliente_key);
CREATE INDEX idx_hpago_vendedor ON HPAGO(vendedor_key);
CREATE INDEX idx_hpago_almacen ON HPAGO(almacen_key);
CREATE INDEX idx_hpago_venta_id ON HPAGO(venta_id);

-- =====================================================
-- VALIDACIÓN DE ESTRUCTURA CREADA
-- =====================================================

SHOW TABLES;

DESCRIBE DTIEMPO;
DESCRIBE DCLIENTE;
DESCRIBE DPRODUCTO;
DESCRIBE DVENDEDOR;
DESCRIBE DALMACEN;
DESCRIBE HVENTA;
DESCRIBE HPAGO;