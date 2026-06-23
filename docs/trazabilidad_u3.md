# Trazabilidad fuente-modelo-KPI-dashboard

Esta sección documenta la trazabilidad de los principales indicadores del producto BI U3, desde la fuente transaccional hasta el dashboard de Power BI.

| KPI | Fuente OLTP | Capa RAW | Modelo dbt / Marts | Medida Power BI | Página dashboard | Validación |
|---|---|---|---|---|---|---|
| Ventas Facturadas | ventas, detalle_ventas | raw.ventas, raw.detalle_ventas | marts.fact_ventas | Ventas Facturadas | Resumen Ejecutivo / Comparativo U3 | SQL vs Power BI |
| Ventas Año Anterior | ventas, detalle_ventas | raw.ventas, raw.detalle_ventas | marts.fact_ventas + marts.dim_tiempo | Ventas Año Anterior | Comparativo U3 | validacion_comparativos_u3.sql |
| Variación Ventas YoY | ventas, detalle_ventas | raw.ventas, raw.detalle_ventas | marts.fact_ventas + marts.dim_tiempo | Variación Ventas YoY | Comparativo U3 | validacion_comparativos_u3.sql |
| % Crecimiento YoY | ventas, detalle_ventas | raw.ventas, raw.detalle_ventas | marts.fact_ventas + marts.dim_tiempo | % Crecimiento YoY | Comparativo U3 | validacion_comparativos_u3.sql |
| Ventas Mes Anterior | ventas, detalle_ventas | raw.ventas, raw.detalle_ventas | marts.fact_ventas + marts.dim_tiempo | Ventas Mes Anterior | Comparativo U3 | validacion_comparativos_u3.sql |
| Variación Ventas MoM | ventas, detalle_ventas | raw.ventas, raw.detalle_ventas | marts.fact_ventas + marts.dim_tiempo | Variación Ventas MoM | Comparativo U3 | validacion_comparativos_u3.sql |
| % Crecimiento MoM | ventas, detalle_ventas | raw.ventas, raw.detalle_ventas | marts.fact_ventas + marts.dim_tiempo | % Crecimiento MoM | Comparativo U3 | validacion_comparativos_u3.sql |
| Ventas Netas sin IGV | ventas, detalle_ventas | raw.ventas, raw.detalle_ventas | marts.fact_ventas | Ventas Netas sin IGV | Resumen Ejecutivo | validacion_marts.sql |
| Margen Bruto | ventas, detalle_ventas, productos | raw.ventas, raw.detalle_ventas, raw.productos | marts.fact_ventas | Margen Bruto | Resumen Ejecutivo / Productos y Rentabilidad | validacion_marts.sql |
| % Margen Bruto | ventas, detalle_ventas, productos | raw.ventas, raw.detalle_ventas, raw.productos | marts.fact_ventas | % Margen Bruto | Resumen Ejecutivo / Productos y Rentabilidad | SQL vs Power BI |
| Monto Pagado | pagos | raw.pagos | marts.fact_pagos | Monto Pagado | Cobranza y Tiempo | validacion_marts.sql |
| Saldo Pendiente | pagos | raw.pagos | marts.fact_pagos | Saldo Pendiente | Cobranza y Tiempo | validacion_marts.sql |
| % Cobrado | pagos | raw.pagos | marts.fact_pagos | % Cobrado | Cobranza y Tiempo | SQL vs Power BI |
| DSO Promedio | pagos | raw.pagos | marts.fact_pagos | DSO Promedio | Cobranza y Tiempo | SQL vs Power BI |

## Evidencia de validación

La validación de comparativos U3 se realizó mediante el archivo:

`dw-dbt/rico_bi/rico_bi/analyses/validacion_comparativos_u3.sql`

Para el periodo enero 2025, los resultados SQL coinciden con Power BI:

| Métrica | Resultado |
|---|---:|
| Ventas actuales | S/ 17,189,473.94 |
| Ventas año anterior | S/ 17,278,131.27 |
| Variación YoY | -S/ 88,657.33 |
| % YoY | -0.51 % |
| Ventas mes anterior | S/ 30,390,295.52 |
| Variación MoM | -S/ 13,200,821.58 |
| % MoM | -43.44 % |