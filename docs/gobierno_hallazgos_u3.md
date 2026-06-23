# Gobierno mínimo de datos, hallazgos y decisión recomendada

## 1. Gobierno mínimo de datos

El producto BI Rico BI establece un gobierno mínimo de datos para asegurar que los indicadores utilizados en el dashboard tengan una fuente definida, una regla de cálculo conocida, una frecuencia de actualización y un responsable funcional.

| KPI                  | Fuente oficial                     | Capa analítica                       | Regla de cálculo                               | Frecuencia | Responsable               | Criterio de calidad                 |
| -------------------- | ---------------------------------- | ------------------------------------ | ---------------------------------------------- | ---------- | ------------------------- | ----------------------------------- |
| Ventas Facturadas    | ventas, detalle_ventas             | marts.fact_ventas                    | SUM(venta_facturada_con_igv)                   | Diaria     | Gerencia comercial        | Diferencia SQL vs Power BI = 0.00   |
| Ventas Netas sin IGV | ventas, detalle_ventas             | marts.fact_ventas                    | SUM(venta_neta_sin_igv)                        | Diaria     | Gerencia comercial        | Sin valores nulos críticos          |
| Margen Bruto         | ventas, detalle_ventas, productos  | marts.fact_ventas                    | SUM(margen_bruto)                              | Diaria     | Gerencia comercial        | Cálculo sobre venta neta sin IGV    |
| % Margen Bruto       | fact_ventas                        | marts.fact_ventas                    | Margen Bruto / Ventas Netas sin IGV            | Diaria     | Gerencia comercial        | Coincidencia SQL vs Power BI        |
| Monto Pagado         | pagos                              | marts.fact_pagos                     | SUM(monto_pagado)                              | Diaria     | Administración / cobranza | Diferencia SQL vs Power BI = 0.00   |
| Saldo Pendiente      | pagos                              | marts.fact_pagos                     | SUM(saldo_pendiente)                           | Diaria     | Administración / cobranza | Sin montos negativos inconsistentes |
| % Cobrado            | pagos                              | marts.fact_pagos                     | Monto Pagado / Monto Total                     | Diaria     | Administración / cobranza | Validación contra fact_pagos        |
| DSO Promedio         | pagos                              | marts.fact_pagos                     | AVERAGE(dias_cobro)                            | Diaria     | Área de cobranza          | Fechas de emisión y pago válidas    |
| Ventas Año Anterior  | ventas, detalle_ventas, dim_tiempo | marts.fact_ventas + marts.dim_tiempo | Comparación con mismo periodo del año anterior | Mensual    | Gerencia comercial        | Validado con SQL U3                 |
| Ventas Mes Anterior  | ventas, detalle_ventas, dim_tiempo | marts.fact_ventas + marts.dim_tiempo | Comparación con mes anterior                   | Mensual    | Gerencia comercial        | Validado con SQL U3                 |

## 2. Hallazgos principales

La solución BI permitió identificar que, para enero de 2025, las ventas facturadas fueron de S/ 17,189,473.94, mientras que en el mismo mes del año anterior fueron S/ 17,278,131.27. Esto representa que en el mismo mes del año anterior fueron S/ 17,278,131.27. Esto representa una variación YoY de -S/ 88,657.33 y un crecimiento de -0.51 %, lo que indica una ligera disminución interanual.

En comparación con el mes anterior, enero de 2025 presentó ventas por S/ 17,189,473.94 frente a S/ 30,390,295.52 del periodo previo. La variación MoM fue de -S/ 13,200,821.58, equivalente a -43.44 %. Este resultado evidencia una caída mensual fuerte que debe ser revisada por gerencia comercial.

Por categoría, la línea POLLO concentra la mayor parte de la facturación, con S/ 14,499,159.44 en enero de 2025. Sin embargo, presenta una reducción YoY de -S/ 264,110.41. En contraste, la categoría CERDO muestra crecimiento interanual positivo de S/ 415,445.93, equivalente a 33.04 %.

La categoría EMBUTIDOS registra una caída YoY de -S/ 243,498.47, equivalente a -19.78 %. Este comportamiento sugiere revisar rotación, precios, promociones o abastecimiento de dicha categoría.

## 3. Interpretación de negocio

El dashboard evidencia que el negocio mantiene un volumen importante de facturación, pero presenta señales de alerta en la evolución mensual. La caída MoM de -43.44 % indica que enero de 2025 tuvo un desempeño menor frente al mes anterior, por lo que se recomienda revisar si la disminución responde a estacionalidad, menor demanda, reducción de pedidos, quiebre de stock o menor desempeño comercial.

El análisis por categoría muestra que no todas las líneas se comportan igual. CERDO tiene crecimiento positivo, mientras POLLO y EMBUTIDOS requieren seguimiento. Por ello, el análisis no debe limitarse al total general, sino que debe evaluarse por categoría, vendedor y periodo.

## 4. Decisión recomendada

Se recomienda priorizar una estrategia comercial diferenciada por categoría. Para POLLO, se debe proteger el volumen de ventas mediante seguimiento a clientes principales y vendedores con mayor participación. Para EMBUTIDOS, se recomienda revisar precios, rotación y promociones, debido a su caída interanual. Para CERDO, se recomienda reforzar la estrategia comercial porque muestra crecimiento positivo y puede compensar parcialmente la caída de otras categorías.

Asimismo, se recomienda que gerencia comercial revise mensualmente el dashboard Comparativo U3, especialmente las medidas de Ventas Facturadas, Ventas Año Anterior, Variación YoY, Ventas Mes Anterior y Variación MoM. Esta revisión permitirá tomar decisiones oportunas sobre ventas, campañas comerciales, gestión de vendedores y abastecimiento.
