# Proyecto BI - Corporación Rico S.A.C.

Manual de usuario y guía para levantar el proyecto completo.

## 1. Objetivo

Este proyecto implementa un flujo de Business Intelligence basado en Docker, siguiendo la lógica del repositorio guía del curso:

```text
MySQL OLTP -> Airbyte -> PostgreSQL RAW -> dbt STAGING -> dbt MARTS
```

Además, se dejó una versión manual del Data Warehouse en MySQL para demostrar la construcción de dimensiones y hechos con SQL.

## 2. Estructura del proyecto

```text
D:\rico-bi
├── oltp-mysql
│   ├── docker-compose.yml
│   ├── 01_rico_oltp_completo.sql
│   └── 02_validar_rico_oltp.sql
│
├── dw-mysql
│   ├── 03_crear_dw_rico.sql
│   ├── 04_cargar_dimensiones.sql
│   ├── 05_cargar_hechos.sql
│   └── 06_validar_dw_rico.sql
│
├── dw-pg
│   ├── docker-compose.yml
│   ├── 01_init_dw_pg.sql
│   └── 02_crear_raw_tables.sql
│
├── ingesta-airbyte
│   └── configuración realizada en la interfaz web de Airbyte
│
└── dw-dbt
    ├── docker-compose.yml
    ├── Dockerfile
    ├── requirements.txt
    ├── profiles
    │   └── profiles.yml
    └── rico_bi
        └── rico_bi
            ├── dbt_project.yml
            ├── models
            │   ├── staging
            │   └── marts
            ├── analyses
            │   └── validacion_marts.sql
            └── macros
```

## 3. Requisitos

Instalar previamente:

```text
Docker Desktop
Docker Compose
Git
Visual Studio Code
abctl
```

No es necesario instalar MySQL, PostgreSQL ni dbt directamente en Windows porque se usan mediante Docker.

Verificar herramientas:

```bash
docker --version
docker compose version
git --version
abctl version
docker run hello-world
```

## 4. Levantar MySQL OLTP

```bash
cd D:\rico-bi\oltp-mysql
docker compose up -d
docker ps
```

Debe aparecer el contenedor:

```text
rico-oltp-mysql
```

Entrar a MySQL:

```bash
docker exec -it rico-oltp-mysql mysql -uroot -proot
```

Validar:

```sql
SHOW DATABASES;
USE rico_oltp;
SHOW TABLES;
```

Tablas esperadas:

```text
almacenes
clientes
detalle_ventas
pagos
productos
vendedores
ventas
```

Conteos esperados:

```text
clientes             120
productos             33
vendedores             5
almacenes              2
ventas             80674
detalle_ventas    162858
pagos              80674
```

Salir:

```sql
exit;
```

## 5. Validar OLTP

```bash
cd D:\rico-bi\oltp-mysql
docker exec -i rico-oltp-mysql mysql -uroot -proot < 02_validar_rico_oltp.sql
```

Esta validación revisa ventas sin detalle, detalles sin venta, pagos sin venta, productos inexistentes, clientes inexistentes, vendedores inexistentes, almacenes inexistentes, importes negativos y diferencias fuertes de totales.

## 6. Crear y validar DW manual en MySQL

```bash
cd D:\rico-bi\dw-mysql
docker exec -i rico-oltp-mysql mysql -uroot -proot < 03_crear_dw_rico.sql
docker exec -i rico-oltp-mysql mysql -uroot -proot < 04_cargar_dimensiones.sql
docker exec -i rico-oltp-mysql mysql -uroot -proot < 05_cargar_hechos.sql
docker exec -i rico-oltp-mysql mysql -uroot -proot < 06_validar_dw_rico.sql
```

Resultados esperados:

```text
DTIEMPO       859
DCLIENTE      120
DPRODUCTO      33
DVENDEDOR       5
DALMACEN        2
HVENTA      162858
HPAGO        80674
```

Indicadores principales:

```text
Ventas totales:          605,829,795.16
Costos totales:          359,231,887.29
Margen bruto total:      246,597,995.10
Monto total pagos:       605,829,797.97
Monto pagado:            583,672,506.05
Saldo pendiente:          22,157,291.92
```

## 7. Levantar PostgreSQL DW

```bash
cd D:\rico-bi\dw-pg
docker compose up -d
docker ps
```

Debe aparecer:

```text
rico-dw-postgres
```

Entrar:

```bash
docker exec -it rico-dw-postgres psql -U postgres -d rico_dw
```

Validar schemas:

```sql
\dn
```

Schemas esperados:

```text
raw
staging
marts
public
```

Salir:

```sql
\q
```

## 8. Crear tablas RAW

```bash
cd D:\rico-bi\dw-pg
docker exec -i rico-dw-postgres psql -U postgres -d rico_dw < 02_crear_raw_tables.sql
```

Validar:

```bash
docker exec -it rico-dw-postgres psql -U postgres -d rico_dw
```

```sql
\dt raw.*
```

Tablas esperadas:

```text
raw.almacenes
raw.clientes
raw.detalle_ventas
raw.pagos
raw.productos
raw.vendedores
raw.ventas
```

## 9. Levantar Airbyte

```bash
cd D:\rico-bi\ingesta-airbyte
abctl local status
```

Si no está activo:

```bash
abctl local install --port 8010
```

Obtener credenciales:

```bash
abctl local credentials
```

Abrir en navegador:

```text
http://localhost:8010
```

## 10. Configurar Airbyte

### Source MySQL

```text
Tipo: MySQL
Name: rico_oltp_mysql
Host: host.docker.internal
Port: 13306
Database: rico_oltp
Username: root
Password: root
Encryption: preferred
SSH Tunnel Method: No Tunnel
```

### Destination PostgreSQL

```text
Tipo: Postgres
Name: rico_dw_postgres_raw
Host: host.docker.internal
Port: 15432
Database: rico_dw
Default Schema: raw
Username: postgres
Password: postgres
SSL: disable
SSH Tunnel Method: No Tunnel
```

Streams seleccionados:

```text
almacenes
clientes
detalle_ventas
pagos
productos
vendedores
ventas
```

Modo:

```text
Full refresh | Overwrite
```

Frecuencia:

```text
Every 24 hours
```

Ejecutar:

```text
Finish & Sync
```

## 11. Validar RAW después de Airbyte

```bash
docker exec -it rico-dw-postgres psql -U postgres -d rico_dw
```

```sql
SELECT 'almacenes' AS tabla, COUNT(*) AS total FROM raw.almacenes
UNION ALL
SELECT 'clientes', COUNT(*) FROM raw.clientes
UNION ALL
SELECT 'detalle_ventas', COUNT(*) FROM raw.detalle_ventas
UNION ALL
SELECT 'pagos', COUNT(*) FROM raw.pagos
UNION ALL
SELECT 'productos', COUNT(*) FROM raw.productos
UNION ALL
SELECT 'vendedores', COUNT(*) FROM raw.vendedores
UNION ALL
SELECT 'ventas', COUNT(*) FROM raw.ventas;
```

Resultado esperado:

```text
almacenes             2
clientes            120
productos            33
vendedores            5
pagos             80674
ventas            80674
detalle_ventas   162858
```

Salir:

```sql
\q
```

## 12. Levantar dbt con Docker

```bash
cd D:\rico-bi\dw-dbt
docker network create rico-bi-net
docker network connect rico-bi-net rico-dw-postgres
docker compose up -d --build
docker compose ps
```

Debe aparecer:

```text
rico-dw-dbt
```

Entrar:

```bash
docker exec -it rico-dw-dbt bash
```

Validar:

```bash
dbt --version
```

## 13. Ejecutar dbt

Dentro del contenedor:

```bash
cd /usr/app/rico_bi/rico_bi
dbt debug
```

Resultado esperado:

```text
All checks passed!
```

Ejecutar staging:

```bash
dbt run --select staging
```

Resultado esperado:

```text
PASS=7 ERROR=0
```

Ejecutar marts:

```bash
dbt run --select marts
```

Resultado esperado:

```text
PASS=7 ERROR=0
```

Ejecutar pruebas:

```bash
dbt test
```

Resultado esperado:

```text
PASS=40 WARN=0 ERROR=0 SKIP=0 TOTAL=40
```

## 14. Validación final de marts

Dentro del contenedor dbt:

```bash
dbt compile --select validacion_marts
exit
```

Desde Windows CMD:

```bash
cd D:\rico-bi\dw-dbt\rico_bi\rico_bi
docker exec -i rico-dw-postgres psql -U postgres -d rico_dw < target\compiled\rico_bi\analyses\validacion_marts.sql
```

Resultados esperados:

```text
dim_cliente       120
dim_almacen         2
dim_producto       33
dim_vendedor        5
dim_tiempo        859
fact_pagos      80674
fact_ventas    162858
```

Ventas:

```text
ventas_raw      605,829,795.16
ventas_marts    605,829,795.16
diferencia                0.00
```

Pagos:

```text
pagos_raw       605,829,797.97
pagos_marts     605,829,797.97
diferencia                0.00
```

Indicadores principales:

```text
Ventas totales:          605,829,795.16
Costos totales:          359,231,887.29
Margen bruto total:      246,597,995.10
Margen global:                    40.70 %
Monto total pagos:       605,829,797.97
Monto pagado:            583,672,506.05
Saldo pendiente:          22,157,291.92
Porcentaje cobrado:               96.34 %
Porcentaje pendiente:              3.66 %
```

## 15. Orden recomendado para levantar todo después

Cuando se quiera abrir el proyecto nuevamente:

```bash
cd D:\rico-bi\oltp-mysql
docker compose up -d
```

```bash
cd D:\rico-bi\dw-pg
docker compose up -d
```

```bash
cd D:\rico-bi\dw-dbt
docker compose up -d
```

Verificar:

```bash
docker ps
```

Revisar Airbyte:

```bash
abctl local status
```

Abrir:

```text
http://localhost:8010
```

Entrar a dbt:

```bash
docker exec -it rico-dw-dbt bash
cd /usr/app/rico_bi/rico_bi
dbt debug
dbt run --select staging
dbt run --select marts
dbt test
```

## 16. Comandos útiles

Ver contenedores:

```bash
docker ps
```

Entrar a MySQL:

```bash
docker exec -it rico-oltp-mysql mysql -uroot -proot
```

Entrar a PostgreSQL:

```bash
docker exec -it rico-dw-postgres psql -U postgres -d rico_dw
```

Entrar a dbt:

```bash
docker exec -it rico-dw-dbt bash
```

Apagar MySQL:

```bash
cd D:\rico-bi\oltp-mysql
docker compose down
```

Apagar PostgreSQL:

```bash
cd D:\rico-bi\dw-pg
docker compose down
```

Apagar dbt:

```bash
cd D:\rico-bi\dw-dbt
docker compose down
```

Reiniciar MySQL borrando volumen:

```bash
cd D:\rico-bi\oltp-mysql
docker compose down -v
docker compose up -d
```

Reiniciar PostgreSQL borrando volumen:

```bash
cd D:\rico-bi\dw-pg
docker compose down -v
docker compose up -d
```

Credenciales Airbyte:

```bash
abctl local credentials
```

## 17. Estado final

```text
oltp-mysql        completado
dw-mysql          completado como versión manual
dw-pg             completado
ingesta-airbyte   completado
dw-dbt            completado
validaciones      completadas
powerbi           pendiente para etapa posterior
```

## 18. Explicación para presentación

El proyecto implementa una arquitectura BI basada en contenedores Docker. Primero se levanta una base transaccional MySQL llamada `rico_oltp`. Luego se valida su calidad. Después, mediante Airbyte, se realiza la ingesta hacia PostgreSQL en el esquema `raw`. Posteriormente, dbt transforma los datos hacia `staging` y finalmente construye el modelo analítico en `marts`, compuesto por dimensiones y tablas de hechos. El flujo fue validado con pruebas dbt y consultas de métricas, obteniendo diferencias de `0.00` entre la capa `raw` y la capa `marts`.
