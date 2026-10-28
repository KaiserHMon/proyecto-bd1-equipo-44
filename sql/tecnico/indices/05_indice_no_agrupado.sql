-- Prueba 4: indice no agrupado sobre la fecha, sin columnas incluidas
-- El motor encuentra el periodo con el indice, pero como las columnas del
-- SELECT no estan adentro, tiene que ir a buscar cada fila.
USE supermercado_db;
GO


CREATE NONCLUSTERED INDEX ix_venta_historica_fecha_no_agrupado
ON dbo.venta_historica (fecha_venta);
GO

SELECT name AS indice, type_desc AS tipo
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.venta_historica');
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- La misma consulta de las pruebas anteriores
SELECT
    fecha_venta,
    monto_total,
    estado,
    id_medio_pago,
    id_persona
FROM dbo.venta_historica
WHERE fecha_venta >= '2026-03-02'
  AND fecha_venta <  '2026-03-09'
ORDER BY fecha_venta;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

SELECT TOP (3)
    qs.execution_count AS ejecuciones,
    qs.last_logical_reads AS lecturas_logicas,
    qs.last_physical_reads AS lecturas_fisicas,
    qs.last_elapsed_time / 1000.0 AS ultimo_tiempo_ms,
    qp.query_plan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE st.text LIKE '%venta_historica%'
ORDER BY qs.last_execution_time DESC;
GO
