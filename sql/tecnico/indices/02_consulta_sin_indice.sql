-- Prueba 1: busqueda por periodo SIN indice
USE supermercado_db;
GO

-- Esto lo usamos para medir el tiempo de respuesta en ms, hay que activarlo
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Listado de ventas de la primera semana de marzo de 2026
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


/* Plan que dejo la consulta en cache. */
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
