-- Limpieza de la prueba de indices
-- Borra la tabla con el millon de filas y la tabla auxiliar de numeros.
-- Conviene correrlo despues de tomar las mediciones, porque volver a cargar
-- el millon de filas lleva unos minutos.

USE supermercado_db;
GO

DROP TABLE dbo.venta_historica;
GO

DROP TABLE dbo.numeros;
GO
