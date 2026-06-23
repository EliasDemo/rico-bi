# Informe final U3 - Producto BI end-to-end

## 1. Datos generales

| Campo                | Detalle                                                     |
| -------------------- | ----------------------------------------------------------- |
| Proyecto             | Rico BI                                                     |
| Empresa analizada    | Corporación Rico S.A.C.                                     |
| Proceso de negocio   | Ventas, productos, clientes, vendedores, almacén y cobranza |
| Fuente transaccional | MySQL OLTP `rico_oltp`                                      |
| Data Warehouse       | PostgreSQL `rico_dw`                                        |
| Herramientas         | MySQL, Airbyte, PostgreSQL, dbt, Power BI, Docker, MkDocs   |
| Repositorio          | https://github.com/EliasDemo/rico-bi                        |
| Documentación        | https://EliasDemo.github.io/rico-bi/                        |

## 2. Resumen ejecutivo

Rico BI implementa una solución Business Intelligence end-to-end para analizar ventas, rentabilidad y cobranza de Corporación Rico S.A.C. El proyecto integra una fuente transaccional MySQL, un proceso de ingesta con Airbyte, un Data Warehouse en PostgreSQL, transformaciones con dbt, un modelo semántico en Power BI y dashboards interactivos para la toma de decisiones.

La solución permite medir ventas facturadas, ventas netas sin IGV, margen bruto, porcentaje de margen, monto pagado, saldo pendiente, porcentaje cobrado, DSO promedio, variaciones YoY y MoM. Los indicadores fueron validados mediante SQL y contrastados con Power BI.

## 3. Arquitectura BI implementada

El flujo implementado es:

MySQL OLTP → Airbyte → PostgreSQL RAW → dbt STAGING → dbt MARTS → Power BI

La arquitectura separa la base transaccional de la base analítica. MySQL funciona como sistema origen; Airbyte replica los datos hacia PostgreSQL en la capa raw; dbt transforma los datos hacia staging y marts; finalmente, Power BI consume el modelo dimensional para construir dashboards ejecutivos.

## 4. Modelo analítico

El DataMart se construyó bajo un modelo dimensional tipo estrella, compuesto por dimensiones y tablas de hechos.

| Tipo      | Tabla        | Descripción                            |
| --------- | ------------ | -------------------------------------- |
| Dimensión | dim_tiempo   | Calendario analítico                   |
| Dimensión | dim_cliente  | Clientes, tipo y ubicación             |
| Dimensión | dim_producto | Productos, categorías, precios y stock |
| Dimensión | dim_vendedor | Vendedores y zonas                     |
| Dimensión | dim_almacen  | Almacenes y ubicación                  |
| Hecho     | fact_ventas  | Ventas a nivel de detalle              |
| Hecho     | fact_pagos   | Pagos, cobranza y mora                 |

## 5. KPIs principales

| KPI                  |       Resultado |
| -------------------- | --------------: |
| Ventas facturadas    | S/ 605.83 mill. |
| Ventas netas sin IGV | S/ 513.42 mill. |
| Margen bruto         | S/ 154.18 mill. |
| % margen bruto       |         30.03 % |
| Monto pagado         | S/ 583.67 mill. |
| Saldo pendiente      |  S/ 22.16 mill. |
| % cobrado            |         96.34 % |
| DSO promedio         |      12.27 días |

## 6. Comparativos U3

Para cumplir el análisis comparativo de la Unidad 3, se agregó una página en Power BI denominada `Comparativo U3`. Esta página permite comparar el periodo actual contra el mismo periodo del año anterior y contra el mes anterior.

Para enero de 2025, los resultados fueron:

| Métrica             |         Resultado |
| ------------------- | ----------------: |
| Ventas actuales     |  S/ 17,189,473.94 |
| Ventas año anterior |  S/ 17,278,131.27 |
| Variación YoY       |     -S/ 88,657.33 |
| % YoY               |           -0.51 % |
| Ventas mes anterior |  S/ 30,390,295.52 |
| Variación MoM       | -S/ 13,200,821.58 |
| % MoM               |          -43.44 % |

## 7. Validación SQL

La validación de comparativos se realizó mediante el archivo:

`dw-dbt/rico_bi/rico_bi/analyses/validacion_comparativos_u3.sql`

Los resultados SQL coinciden con las tarjetas y matriz del dashboard Power BI. Esto demuestra consistencia entre el DataMart y el modelo semántico.

## 8. Trazabilidad

La trazabilidad se documentó en MkDocs mediante la página `Trazabilidad U3`. Esta matriz relaciona cada KPI con su fuente OLTP, capa raw, modelo dbt, medida Power BI, página del dashboard y consulta de validación.

## 9. Gobierno mínimo de datos

Se estableció un gobierno mínimo de datos para definir fuente oficial, regla de cálculo, frecuencia, responsable y criterio de calidad de cada KPI. Esto permite controlar el uso de los indicadores y asegurar que las decisiones se basen en métricas confiables.

## 10. Hallazgos principales

En enero de 2025, las ventas facturadas fueron S/ 17,189,473.94. Frente al mismo mes del año anterior, se observa una ligera disminución de -0.51 %. Sin embargo, frente al mes anterior, la caída fue de -43.44 %, lo que representa una señal de alerta comercial.

Por categoría, POLLO concentra la mayor facturación, pero presenta una reducción interanual. CERDO muestra crecimiento positivo, mientras EMBUTIDOS presenta caída relevante. Esto evidencia que el desempeño no es homogéneo entre categorías.

## 11. Decisión recomendada

Se recomienda aplicar una estrategia comercial diferenciada por categoría. Para POLLO, se debe proteger el volumen de ventas mediante seguimiento a clientes principales y vendedores clave. Para EMBUTIDOS, se recomienda revisar precios, promociones, rotación y abastecimiento. Para CERDO, se recomienda reforzar la estrategia comercial porque muestra crecimiento positivo.

Asimismo, se recomienda que gerencia comercial revise mensualmente el dashboard `Comparativo U3` para monitorear ventas, variaciones YoY, variaciones MoM, margen y cobranza.

## 12. Evidencias entregables

| Evidencia                   | Estado     |
| --------------------------- | ---------- |
| Repositorio GitHub          | Completado |
| README principal            | Completado |
| MkDocs publicado            | Completado |
| OLTP MySQL                  | Completado |
| Airbyte                     | Completado |
| PostgreSQL DW               | Completado |
| dbt staging y marts         | Completado |
| Pruebas dbt                 | Completado |
| Power BI base               | Completado |
| Power BI U3                 | Completado |
| Validación SQL comparativos | Completado |
| Trazabilidad U3             | Completado |
| Gobierno y hallazgos        | Completado |

## 13. Conclusión

El proyecto Rico BI cumple con el enfoque BI end-to-end solicitado para la Unidad 3. La solución integra datos desde el origen transaccional hasta el dashboard, mantiene trazabilidad, valida los KPIs con SQL y permite generar hallazgos de negocio para apoyar decisiones comerciales, financieras y de cobranza.
