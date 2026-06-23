# Evidencias U3

## 1. Repositorio y documentación

| Evidencia            | Enlace / ubicación                   |
| -------------------- | ------------------------------------ |
| Repositorio GitHub   | https://github.com/EliasDemo/rico-bi |
| GitHub Pages MkDocs  | https://EliasDemo.github.io/rico-bi/ |
| README principal     | `README.md`                          |
| Configuración MkDocs | `mkdocs.yml`                         |

## 2. Archivos técnicos

| Evidencia                  | Ubicación                                                        |
| -------------------------- | ---------------------------------------------------------------- |
| OLTP MySQL                 | `oltp-mysql/01_rico_oltp_completo.sql`                           |
| Validación OLTP            | `oltp-mysql/02_validar_rico_oltp.sql`                            |
| DW manual                  | `dw-mysql/`                                                      |
| PostgreSQL DW              | `dw-pg/`                                                         |
| Proyecto dbt               | `dw-dbt/rico_bi/rico_bi/`                                        |
| Validación marts           | `dw-dbt/rico_bi/rico_bi/analyses/validacion_marts.sql`           |
| Validación comparativos U3 | `dw-dbt/rico_bi/rico_bi/analyses/validacion_comparativos_u3.sql` |

## 3. Power BI

| Evidencia          | Ubicación                                |
| ------------------ | ---------------------------------------- |
| Dashboard base     | `powerbi/rico_pollo_actualizado.pbix`    |
| Dashboard U3       | `powerbi/rico_pollo_actualizado_U3.pbix` |
| Página U3 agregada | `Comparativo U3`                         |

## 4. Documentos finales

| Documento                        | Estado     |
| -------------------------------- | ---------- |
| Informe final U3 actualizado     | Completado |
| PPT de sustentación U3           | Completado |
| Matriz de trazabilidad           | Completado |
| Gobierno mínimo de datos         | Completado |
| Hallazgos y decisión recomendada | Completado |

## 5. Validación de comparativos

La consulta SQL `validacion_comparativos_u3.sql` valida los resultados mostrados en Power BI para enero de 2025.

| Métrica             |     Resultado SQL | Resultado Power BI | Estado   |
| ------------------- | ----------------: | -----------------: | -------- |
| Ventas actuales     |  S/ 17,189,473.94 |     S/ 17.19 mill. | Coincide |
| Ventas año anterior |  S/ 17,278,131.27 |     S/ 17.28 mill. | Coincide |
| Variación YoY       |     -S/ 88,657.33 |      -S/ 88.66 mil | Coincide |
| % YoY               |           -0.51 % |            -0.51 % | Coincide |
| Ventas mes anterior |  S/ 30,390,295.52 |     S/ 30.39 mill. | Coincide |
| Variación MoM       | -S/ 13,200,821.58 |    -S/ 13.20 mill. | Coincide |
| % MoM               |          -43.44 % |           -43.44 % | Coincide |
