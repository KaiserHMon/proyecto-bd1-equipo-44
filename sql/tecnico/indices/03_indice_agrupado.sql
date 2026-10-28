-- Prueba 2: indice agrupado sobre la columna de fecha
-- La tabla queda ordenada fisicamente por fecha_venta, asi que el motor
-- puede ubicar el periodo y leer solo esas paginas.
USE supermercado_db;
GO


CREATE CLUSTERED INDEX ix_venta_historica_fecha
ON dbo.venta_historica (fecha_venta);
GO

-- El indice tiene que aparecer como CLUSTERED
SELECT name AS indice, type_desc AS tipo
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.venta_historica');
GO


SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- La misma consulta de la prueba 1
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
