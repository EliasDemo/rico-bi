# Rico BI

Documentación técnica del proyecto **Rico BI**, solución Business Intelligence end-to-end para Corporación Rico S.A.C.

## Flujo general

MySQL OLTP → Airbyte → PostgreSQL RAW → dbt STAGING → dbt MARTS → Power BI

## Componentes documentados

- Fuente transaccional OLTP
- Ingesta con Airbyte
- Data Warehouse en PostgreSQL
- Transformaciones con dbt
- DataMart dimensional
- Modelo semántico en Power BI
- Validaciones SQL y dbt
- Sustentación técnica del producto U3