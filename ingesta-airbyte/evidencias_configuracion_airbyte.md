# Evidencias de configuración Airbyte

Esta carpeta documenta la configuración de ingesta utilizada en el proyecto Rico BI.

## Flujo de ingesta

MySQL OLTP `rico_oltp` → Airbyte → PostgreSQL `rico_dw.raw`

## Source MySQL

- Tipo: MySQL
- Nombre: rico_oltp_mysql
- Host: host.docker.internal
- Puerto: 13306
- Base de datos: rico_oltp
- Usuario: root

## Destination PostgreSQL

- Tipo: PostgreSQL
- Nombre: rico_dw_postgres_raw
- Host: host.docker.internal
- Puerto: 15432
- Base de datos: rico_dw
- Schema destino: raw
- Usuario: postgres

## Streams sincronizados

- almacenes
- clientes
- detalle_ventas
- pagos
- productos
- vendedores
- ventas

## Estado

La sincronización fue validada comparando conteos entre MySQL OLTP y PostgreSQL RAW.