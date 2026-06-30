USE rico_oltp;

START TRANSACTION;

SET @venta_id = (SELECT COALESCE(MAX(venta_id), 0) + 1 FROM ventas);
SET @detalle_id = (SELECT COALESCE(MAX(detalle_id), 0) + 1 FROM detalle_ventas);
SET @pago_id = (SELECT COALESCE(MAX(pago_id), 0) + 1 FROM pagos);

SET @cliente_id = (SELECT cliente_id FROM clientes ORDER BY cliente_id LIMIT 1);
SET @vendedor_id = (SELECT vendedor_id FROM vendedores ORDER BY vendedor_id LIMIT 1);
SET @almacen_id = (SELECT almacen_id FROM almacenes ORDER BY almacen_id LIMIT 1);

SET @producto_id = COALESCE(
    (SELECT producto_id FROM productos WHERE activo = 1 AND categoria = 'POLLO' ORDER BY producto_id LIMIT 1),
    (SELECT producto_id FROM productos WHERE activo = 1 ORDER BY producto_id LIMIT 1)
);

SET @fecha = '2025-01-15';
SET @unidades = 1000;
SET @kilos = 1000.000;
SET @precio = 50.00;
SET @costo = 30.00;
SET @subtotal = 50000.00;
SET @igv = 9000.00;
SET @total = 59000.00;

INSERT INTO ventas (
    venta_id,
    fecha_venta,
    fecha_entrega,
    cliente_id,
    vendedor_id,
    almacen_id,
    tipo_doc,
    serie,
    numero_doc,
    tipo_pago,
    descuento,
    subtotal,
    igv,
    isc,
    total,
    estado,
    zona_entrega,
    vehiculo,
    chofer,
    repartidor
)
VALUES (
    @venta_id,
    @fecha,
    @fecha,
    @cliente_id,
    @vendedor_id,
    @almacen_id,
    'FACT',
    'F999',
    @venta_id,
    'Contado',
    0.00,
    @subtotal,
    @igv,
    0.00,
    @total,
    'Completada',
    'PRUEBA U3',
    'TEST-U3',
    'PRUEBA U3',
    'PRUEBA U3'
);

INSERT INTO detalle_ventas (
    detalle_id,
    venta_id,
    producto_id,
    unidades,
    kilos,
    precio_venta,
    costo_unitario,
    descuento,
    igv_porcentaje,
    igv_monto,
    subtotal,
    total_linea
)
VALUES (
    @detalle_id,
    @venta_id,
    @producto_id,
    @unidades,
    @kilos,
    @precio,
    @costo,
    0.00,
    18.00,
    @igv,
    @subtotal,
    @total
);

INSERT INTO pagos (
    pago_id,
    venta_id,
    tipo_pago,
    plazo_dias,
    fecha_emision,
    fecha_vencimiento,
    fecha_pago,
    monto_total,
    monto_pagado,
    saldo_pendiente,
    estado_pago,
    dias_mora,
    es_credito
)
VALUES (
    @pago_id,
    @venta_id,
    'Contado',
    0,
    @fecha,
    @fecha,
    @fecha,
    @total,
    @total,
    0.00,
    'Pagado',
    0,
    0
);

COMMIT;

SELECT
    @venta_id AS venta_id_insertada,
    @detalle_id AS detalle_id_insertado,
    @pago_id AS pago_id_insertado,
    @producto_id AS producto_id_usado,
    @total AS total_insertado;