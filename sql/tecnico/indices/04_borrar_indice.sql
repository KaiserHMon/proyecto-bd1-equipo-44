-- Prueba 3: se borra el indice agrupado
-- La tabla vuelve a quedar igual que en la prueba 1.
USE supermercado_db;
GO


DROP INDEX ix_venta_historica_fecha ON dbo.venta_historica;
GO

-- No tiene que quedar ningun indice
SELECT name AS indice, type_desc AS tipo
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.venta_historica');
GO
