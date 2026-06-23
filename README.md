<div align="center">

# 🐔 Rico BI  
### Solución BI end-to-end para Corporación Rico S.A.C.

**Ventas · Rentabilidad · Clientes · Vendedores · Cobranza**

<br>

## 🔗 Enlaces del producto

| Recurso | Enlace |
|---|---|
| Repositorio GitHub | https://github.com/EliasDemo/rico-bi |
| Documentación MkDocs | https://EliasDemo.github.io/rico-bi/ |
| Dashboard Power BI U3 | `powerbi/rico_pollo_actualizado_U3.pbix` |
| Dashboard Power BI base | `powerbi/rico_pollo_actualizado.pbix` |
| Validación SQL U3 | `dw-dbt/rico_bi/rico_bi/analyses/validacion_comparativos_u3.sql` |

<br>

![Estado](https://img.shields.io/badge/Estado-U3%20avanzado-2ea44f?style=for-the-badge)
![BI](https://img.shields.io/badge/Business%20Intelligence-End--to--End-1f77b4?style=for-the-badge)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-f2c811?style=for-the-badge&logo=powerbi&logoColor=black)
![dbt](https://img.shields.io/badge/dbt-Transformaciones-ff694b?style=for-the-badge&logo=dbt&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Contenedores-2496ed?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Data%20Warehouse-336791?style=for-the-badge&logo=postgresql&logoColor=white)

<br>

> Proyecto académico orientado a construir una solución BI completa, trazable y validada desde una fuente transaccional hasta un dashboard ejecutivo en Power BI.

</div>

---

## 📌 Vista rápida del proyecto

| Bloque | Descripción |
|---|---|
| **Proyecto** | Rico BI |
| **Empresa analizada** | Corporación Rico S.A.C. |
| **Proceso de negocio** | Ventas, productos, clientes, vendedores, almacén y cobranza |
| **Fuente transaccional** | MySQL OLTP `rico_oltp` |
| **Data Warehouse / DataMart** | PostgreSQL `rico_dw` con esquemas `raw`, `staging` y `marts` |
| **Transformación** | dbt |
| **Visualización** | Power BI |
| **Documentación** | MkDocs publicado en GitHub Pages |
| **Entregable** | Unidad 3: producto BI end-to-end |

---

## 🧭 Índice

- [1. Resumen ejecutivo](#1-resumen-ejecutivo)
- [2. Problema de negocio](#2-problema-de-negocio)
- [3. Objetivo analítico](#3-objetivo-analítico)
- [4. Arquitectura BI](#4-arquitectura-bi)
- [5. Stack tecnológico](#5-stack-tecnológico)
- [6. Estructura del repositorio](#6-estructura-del-repositorio)
- [7. Modelo dimensional](#7-modelo-dimensional)
- [8. KPIs principales](#8-kpis-principales)
- [9. Resultados validados](#9-resultados-validados)
- [10. Dashboard Power BI](#10-dashboard-power-bi)
- [11. Ejecución rápida](#11-ejecución-rápida)
- [12. Validación y calidad de datos](#12-validación-y-calidad-de-datos)
- [13. Comparativos U3 validados](#13-comparativos-u3-validados)
- [14. Evidencias U3](#14-evidencias-u3)
- [15. Integrantes](#15-integrantes)
- [16. Próximos pasos](#16-próximos-pasos)

---

## 1. Resumen ejecutivo

**Rico BI** es una solución de Business Intelligence construida para integrar, transformar, validar y visualizar información comercial y financiera de Corporación Rico S.A.C.

La solución permite analizar:

- ventas facturadas;
- ventas netas sin IGV;
- margen bruto;
- rentabilidad por producto y categoría;
- rendimiento de vendedores;
- clientes principales;
- saldo pendiente de cobranza;
- eficiencia de cobro;
- evolución temporal de ventas;
- comparativos YoY y MoM para el entregable U3.

El flujo implementado es:

```text
MySQL OLTP → Airbyte → PostgreSQL RAW → dbt STAGING → dbt MARTS → Power BI
```

También se conserva una versión manual del Data Warehouse en MySQL para evidenciar el diseño físico de dimensiones y hechos mediante SQL.

---

## 2. Problema de negocio

Corporación Rico S.A.C. necesita una vista analítica integrada para responder preguntas comerciales y financieras que no se resuelven eficientemente desde la base transaccional.

### Preguntas de negocio

| Pregunta | Decisión que permite tomar |
|---|---|
| ¿Qué productos generan mayor venta y margen? | Priorizar productos rentables |
| ¿Qué clientes concentran mayor facturación? | Gestionar clientes estratégicos |
| ¿Qué vendedores tienen mejor rendimiento? | Evaluar desempeño comercial |
| ¿Cuál es la cartera pendiente? | Gestionar cobranza |
| ¿Cómo evolucionan las ventas por periodo? | Detectar tendencias y estacionalidad |
| ¿Qué categorías tienen mayor participación? | Ajustar estrategia comercial |
| ¿Cómo varía la venta frente al año anterior y al mes anterior? | Evaluar crecimiento, caída o estacionalidad |

---

## 3. Objetivo analítico

Construir una solución BI end-to-end que permita analizar el desempeño comercial, la rentabilidad y la cobranza mediante KPIs confiables, trazables y validados entre SQL, DataMart y Power BI.

---

## 4. Arquitectura BI

### 4.1 Flujo general

```mermaid
flowchart LR
    A["MySQL OLTP<br><b>rico_oltp</b>"] --> B["Airbyte<br>Ingesta"]
    B --> C["PostgreSQL DW<br><b>raw</b>"]
    C --> D["dbt<br><b>staging</b>"]
    D --> E["dbt<br><b>marts</b>"]
    E --> F["Power BI<br>Modelo semántico"]
    F --> G["Dashboard<br>KPIs y análisis"]
```

### 4.2 Capas de datos

| Capa | Equivalencia | Propósito | Herramienta |
|---|---|---|---|
| **OLTP** | Sistema origen | Registro transaccional de ventas y pagos | MySQL |
| **RAW** | Bronze | Réplica cruda desde el origen | Airbyte + PostgreSQL |
| **STAGING** | Silver | Limpieza, renombrado y estandarización | dbt |
| **MARTS** | Gold | Modelo dimensional para análisis | dbt + PostgreSQL |
| **SEMÁNTICA** | BI Model | Relaciones, jerarquías y medidas | Power BI |
| **DASHBOARD** | Consumo | Visualización para toma de decisiones | Power BI |

---

## 5. Stack tecnológico

| Componente | Tecnología | Rol en el proyecto |
|---|---|---|
| Base transaccional | MySQL 8.4 | Fuente OLTP |
| Contenedores | Docker / Docker Compose | Aislamiento de servicios |
| Ingesta | Airbyte local con `abctl` | Replicación OLTP → RAW |
| Data Warehouse | PostgreSQL 16 | Base analítica |
| Transformación | dbt + dbt-postgres | Staging, marts y pruebas |
| Modelo semántico | Power BI Desktop | Relaciones y medidas DAX |
| Visualización | Power BI | Dashboard ejecutivo |
| Documentación | MkDocs + GitHub Pages | Documentación técnica del producto |
| Validación | SQL + dbt test + Power BI | Control de calidad y consistencia |

---

## 6. Estructura del repositorio

```text
rico-bi
├── README.md
├── .gitignore
├── mkdocs.yml
├── oltp-mysql
│   ├── docker-compose.yml
│   ├── 01_rico_oltp_completo.sql
│   └── 02_validar_rico_oltp.sql
├── dw-mysql
│   ├── 03_crear_dw_rico.sql
│   ├── 04_cargar_dimensiones.sql
│   ├── 05_cargar_hechos.sql
│   └── 06_validar_dw_rico.sql
├── dw-pg
│   ├── docker-compose.yml
│   ├── 01_init_dw_pg.sql
│   └── 02_crear_raw_tables.sql
├── ingesta-airbyte
│   └── evidencias_configuracion_airbyte.md
├── dw-dbt
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── profiles
│   │   └── profiles.yml
│   └── rico_bi
│       └── rico_bi
│           ├── dbt_project.yml
│           ├── models
│           │   ├── staging
│           │   └── marts
│           ├── analyses
│           │   ├── validacion_marts.sql
│           │   └── validacion_comparativos_u3.sql
│           └── macros
├── powerbi
│   ├── rico_pollo_actualizado.pbix
│   └── rico_pollo_actualizado_U3.pbix
└── docs
    ├── index.md
    ├── guia_ejecucion.md
    └── trazabilidad_u3.md
```

---

## 7. Modelo dimensional

### 7.1 Esquema estrella

```mermaid
erDiagram
    DIM_TIEMPO ||--o{ FACT_VENTAS : filtra
    DIM_CLIENTE ||--o{ FACT_VENTAS : filtra
    DIM_PRODUCTO ||--o{ FACT_VENTAS : filtra
    DIM_VENDEDOR ||--o{ FACT_VENTAS : filtra
    DIM_ALMACEN ||--o{ FACT_VENTAS : filtra

    DIM_TIEMPO ||--o{ FACT_PAGOS : filtra
    DIM_CLIENTE ||--o{ FACT_PAGOS : filtra
    DIM_VENDEDOR ||--o{ FACT_PAGOS : filtra
    DIM_ALMACEN ||--o{ FACT_PAGOS : filtra
```

### 7.2 Dimensiones

| Tabla | Descripción | Uso analítico |
|---|---|---|
| `dim_tiempo` | Calendario analítico | Evolución, MoM, YoY |
| `dim_cliente` | Cliente, tipo y ubicación | Top clientes, segmentación |
| `dim_producto` | Producto, categoría, precios y stock | Rentabilidad y participación |
| `dim_vendedor` | Vendedor y zona comercial | Desempeño de fuerza de ventas |
| `dim_almacen` | Almacén y ubicación | Distribución operativa |

### 7.3 Tablas de hechos

| Tabla | Grano | Uso analítico |
|---|---|---|
| `fact_ventas` | Una fila por línea de detalle de venta | Ventas, margen, productos, clientes y vendedores |
| `fact_pagos` | Una fila por pago asociado a una venta | Cobranza, saldo pendiente, mora y DSO |

---

## 8. KPIs principales

| KPI | Fórmula base | Uso |
|---|---|---|
| Ventas facturadas | `SUM(venta_facturada_con_igv)` | Medir facturación total |
| Ventas netas sin IGV | `SUM(venta_neta_sin_igv)` | Base para rentabilidad |
| Margen bruto | `SUM(margen_bruto)` | Rentabilidad bruta |
| % margen bruto | `Margen Bruto / Ventas Netas sin IGV` | Eficiencia comercial |
| Monto pagado | `SUM(monto_pagado)` | Cobranza efectiva |
| Saldo pendiente | `SUM(saldo_pendiente)` | Cartera por cobrar |
| % cobrado | `Monto Pagado / Monto Total` | Eficiencia de cobranza |
| DSO promedio | `AVERAGE(dias_cobro)` | Días promedio de cobro |
| Ticket promedio | `Ventas Facturadas / Operaciones` | Valor promedio de operación |
| Ventas por vendedor | `SUM(ventas) por vendedor` | Evaluación comercial |
| Ventas año anterior | Ventas del mismo periodo del año anterior | Comparativo YoY |
| Variación Ventas YoY | Ventas actuales - ventas año anterior | Variación absoluta anual |
| % Crecimiento YoY | Variación YoY / ventas año anterior | Variación porcentual anual |
| Ventas mes anterior | Ventas del periodo mensual anterior | Comparativo MoM |
| Variación Ventas MoM | Ventas actuales - ventas mes anterior | Variación absoluta mensual |
| % Crecimiento MoM | Variación MoM / ventas mes anterior | Variación porcentual mensual |

---

## 9. Resultados validados

### 9.1 Conteos principales

| Métrica | Resultado |
|---|---:|
| Clientes | 120 |
| Productos | 33 |
| Vendedores | 5 |
| Almacenes | 2 |
| Ventas | 80,674 |
| Detalle de ventas | 162,858 |
| Pagos | 80,674 |

### 9.2 KPIs finales

| KPI | Resultado validado |
|---|---:|
| Ventas facturadas | S/ 605.83 mill. |
| Ventas netas sin IGV | S/ 513.42 mill. |
| Margen bruto | S/ 154.18 mill. |
| % margen bruto | 30.03 % |
| Monto pagado | S/ 583.67 mill. |
| Saldo pendiente | S/ 22.16 mill. |
| % cobrado | 96.34 % |
| DSO promedio | 12.27 días |

> Las validaciones principales comparan conteos y montos entre OLTP, RAW, MARTS y Power BI. Las diferencias esperadas son `0.00`.

---

## 10. Dashboard Power BI

Archivo principal U3:

```text
powerbi/rico_pollo_actualizado_U3.pbix
```

Archivo base conservado:

```text
powerbi/rico_pollo_actualizado.pbix
```

### Páginas del dashboard

| Página | Objetivo |
|---|---|
| **Resumen ejecutivo** | KPIs principales de ventas, margen y cobranza |
| **Productos y rentabilidad** | Análisis de productos, categorías, kilos vendidos y margen |
| **Clientes y vendedores** | Desempeño por cliente, vendedor, zona y tipo de cliente |
| **Cobranza y evolución temporal** | Pagos, saldo pendiente, DSO y tendencia temporal |
| **Comparativo U3** | Comparativo actual vs año anterior y actual vs mes anterior |

### Componentes U3 incorporados

- Comparativo del periodo actual vs mismo periodo del año anterior.
- Comparativo del periodo actual vs periodo anterior.
- Variación absoluta YoY y MoM.
- Variación porcentual YoY y MoM.
- Tabla KPI de variación por categoría.
- Validación SQL de los comparativos.
- Trazabilidad fuente-modelo-KPI-dashboard publicada en MkDocs.

---

## 11. Ejecución rápida

### 11.1 Levantar MySQL OLTP

```bash
cd oltp-mysql
docker compose up -d
```

Validar OLTP:

```bash
docker exec -i rico-oltp-mysql mysql -uroot -proot < 02_validar_rico_oltp.sql
```

### 11.2 Levantar PostgreSQL DW

```bash
cd ../dw-pg
docker compose up -d
```

Crear tablas RAW:

```bash
docker exec -i rico-dw-postgres psql -U postgres -d rico_dw < 02_crear_raw_tables.sql
```

### 11.3 Configurar Airbyte

```bash
abctl local status
abctl local credentials
```

Abrir Airbyte:

```text
http://localhost:8010
```

Configurar la conexión:

```text
MySQL rico_oltp → PostgreSQL rico_dw.raw
```

### 11.4 Ejecutar dbt

```bash
cd ../dw-dbt
docker compose up -d --build
docker exec -it rico-dw-dbt bash
```

Dentro del contenedor:

```bash
cd /usr/app/rico_bi/rico_bi
dbt debug
dbt run --select staging
dbt run --select marts
dbt test
```

### 11.5 Validar marts

```bash
dbt compile --select validacion_marts
```

Ejecutar el SQL compilado contra PostgreSQL para comparar conteos, ventas, pagos y KPIs.

### 11.6 Validar comparativos U3

Desde la raíz del proyecto:

```bash
docker exec -i rico-dw-postgres psql -U postgres -d rico_dw < dw-dbt\rico_bi\rico_bi\analyses\validacion_comparativos_u3.sql
```

---

## 12. Validación y calidad de datos

### Controles aplicados

| Control | Regla esperada | Resultado |
|---|---|---|
| Completitud | Sin nulos críticos en claves y métricas | PASS |
| Unicidad | Claves sin duplicados | PASS |
| Integridad referencial | Hechos relacionados con dimensiones | PASS |
| Consistencia de montos | Diferencia OLTP/RAW/MARTS igual a 0.00 | PASS |
| Consistencia BI | Power BI coincide con SQL | PASS |
| Comparativos U3 | SQL coincide con Power BI para YoY y MoM | PASS |

### Hallazgos corregidos

| Hallazgo | Impacto | Acción tomada |
|---|---|---|
| Margen calculado con total con IGV | Sobreestimaba rentabilidad | Separación entre venta con IGV y venta neta sin IGV |
| Pagos con múltiples fechas de análisis | Limitaba DSO y cartera vencida | Se agregaron claves y métricas de cobranza |
| Relación innecesaria entre hechos en Power BI | Podía afectar filtros | Se mantuvo modelo estrella con filtros desde dimensiones |
| Nombres largos en visuales | Dificultaba lectura | Se mejoraron títulos, filtros y visuales |
| Comparativo MoM en contexto global | Podía mostrar 0.00 sin filtro mensual | Se validó con periodo específico enero 2025 |

---

## 13. Comparativos U3 validados

El dashboard U3 incorpora una página llamada **Comparativo U3**, orientada a demostrar el análisis del periodo actual frente al mismo periodo del año anterior y frente al periodo mensual anterior.

Periodo usado para la validación:

```text
Año = 2025
Mes = Enero
```

### Resultado total validado por SQL

| Métrica | Resultado |
|---|---:|
| Ventas actuales | S/ 17,189,473.94 |
| Ventas año anterior | S/ 17,278,131.27 |
| Variación YoY | -S/ 88,657.33 |
| % YoY | -0.51 % |
| Ventas mes anterior | S/ 30,390,295.52 |
| Variación MoM | -S/ 13,200,821.58 |
| % MoM | -43.44 % |

### Resultado por categoría

| Categoría | Ventas actuales | Ventas año anterior | Variación YoY | % YoY | Ventas mes anterior | Variación MoM | % MoM |
|---|---:|---:|---:|---:|---:|---:|---:|
| CERDO | S/ 1,672,847.20 | S/ 1,257,401.27 | S/ 415,445.93 | 33.04 % | S/ 3,027,197.71 | -S/ 1,354,350.51 | -44.74 % |
| EMBUTIDOS | S/ 987,791.36 | S/ 1,231,289.83 | -S/ 243,498.47 | -19.78 % | S/ 1,738,380.82 | -S/ 750,589.46 | -43.18 % |
| HUEVO | S/ 29,675.94 | S/ 26,170.32 | S/ 3,505.62 | 13.40 % | S/ 39,770.54 | -S/ 10,094.60 | -25.38 % |
| POLLO | S/ 14,499,159.44 | S/ 14,763,269.85 | -S/ 264,110.41 | -1.79 % | S/ 25,584,946.45 | -S/ 11,085,787.01 | -43.33 % |
| **TOTAL** | **S/ 17,189,473.94** | **S/ 17,278,131.27** | **-S/ 88,657.33** | **-0.51 %** | **S/ 30,390,295.52** | **-S/ 13,200,821.58** | **-43.44 %** |

Archivo de validación:

```text
dw-dbt/rico_bi/rico_bi/analyses/validacion_comparativos_u3.sql
```

---

## 14. Evidencias U3

| Evidencia | Estado |
|---|---|
| Repositorio GitHub | ✅ Publicado |
| README principal | ✅ Completado |
| `.gitignore` limpio | ✅ Completado |
| MkDocs configurado | ✅ Completado |
| GitHub Pages | ✅ Publicado |
| Matriz de trazabilidad U3 | ✅ Completado |
| OLTP MySQL | ✅ Completado |
| DW manual MySQL | ✅ Completado |
| PostgreSQL DW | ✅ Completado |
| Airbyte | ✅ Completado |
| dbt staging | ✅ Completado |
| dbt marts | ✅ Completado |
| Pruebas dbt | ✅ Completado |
| Validación SQL vs marts | ✅ Completado |
| Power BI `.pbix` base | ✅ Completado |
| Power BI `.pbix` U3 | ✅ Completado |
| Comparativos U3 | ✅ Completado |
| Validación SQL de comparativos | ✅ Completado |
| Gobierno mínimo de datos | 🟡 Pendiente |
| Hallazgos y decisión recomendada | 🟡 Pendiente |
| Informe final U3 | 🟡 Pendiente |
| PPT de sustentación | 🟡 Pendiente |

---

## 15. Integrantes

| Integrante | Actividades realizadas |
|---|---|
| **Franck Albertson Coaquira Justo** | Ingesta con Airbyte, transformación con dbt, pruebas dbt, conexión con Power BI, métricas DAX, KPIs visuales, comparativo U3 y validación SQL de comparativos |
| **Abdul Quispe Condori** | Construcción de KPIs, validación OLTP, DW manual, apoyo en implementación con herramientas, Power BI y documentación |
| **Julmer Quispe Apaza** | Apoyo en OLTP, implementación manual del DW, apoyo en pipeline con herramientas y documentación de evidencias |

---

## 16. Próximos pasos

```mermaid
flowchart TD
    A["1. Completar gobierno mínimo de datos"] --> B["2. Redactar hallazgos y decisión recomendada"]
    B --> C["3. Actualizar informe final U3"]
    C --> D["4. Preparar PPT de sustentación"]
    D --> E["5. Revisión final de evidencias"]
```

### Checklist inmediato

- [x] Crear repositorio GitHub.
- [x] Publicar README principal.
- [x] Crear carpeta `docs/`.
- [x] Crear archivo `mkdocs.yml`.
- [x] Pasar el manual largo a `docs/guia_ejecucion.md`.
- [x] Publicar MkDocs en GitHub Pages.
- [x] Crear página `docs/trazabilidad_u3.md`.
- [x] Incluir trazabilidad U3 en el menú de MkDocs.
- [x] Completar página Power BI de comparativos.
- [x] Agregar consulta SQL de validación para comparativos.
- [x] Subir Power BI U3 al repositorio.
- [ ] Completar gobierno mínimo de datos.
- [ ] Redactar hallazgos y decisión recomendada.
- [ ] Actualizar informe final U3.
- [ ] Preparar PPT de sustentación.

---

<div align="center">

### Rico BI  
**Producto BI end-to-end para análisis comercial, rentabilidad y cobranza**

</div>
