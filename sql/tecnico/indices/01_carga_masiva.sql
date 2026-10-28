-- Carga masiva de ventas historicas para la prueba de indices
-- Genera 1.000.000 de filas sobre una tabla que tiene una columna de fecha
-- y que arranca sin ningun indice.

USE supermercado_db;
GO

-- Si quedo una prueba anterior, se borra para empezar de cero
IF OBJECT_ID('dbo.venta_historica', 'U') IS NOT NULL
    DROP TABLE dbo.venta_historica;
GO

/* La tabla no lleva PRIMARY KEY a proposito. Queremos un punto de partida
   sin indices.
   Para despues generar el indice agrupado (se permite uno maximo por tabla)*/
CREATE TABLE dbo.venta_historica (
    id_venta INT IDENTITY(1,1) NOT NULL,
    fecha_venta DATETIME NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL,
    estado VARCHAR(30) NOT NULL,
    actualizado_en DATETIME NULL,
    id_medio_pago INT NOT NULL,
    id_persona INT NOT NULL
);
GO


-- Tabla auxiliar con los numeros del 1 al 1.000.000

IF OBJECT_ID('dbo.numeros', 'U') IS NOT NULL
    DROP TABLE dbo.numeros;
GO

CREATE TABLE dbo.numeros (n INT NOT NULL);
GO

INSERT INTO dbo.numeros (n)
SELECT TOP (1000000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
FROM sys.all_objects AS a
CROSS JOIN sys.all_objects AS b;
GO

IF (SELECT COUNT(*) FROM dbo.numeros) < 1000000
    RAISERROR('No se pudieron generar los 1.000.000 de numeros.', 16, 1);
GO


/* Carga en 10 lotes de 100.000 filas. Los valores salen del numero de fila:

   - fecha_venta: se reparte en los 3 anos que van del 2023-10-01 al
     2026-09-30 (94.608.000 segundos). Se multiplica por 337 y se toma el
     resto, asi las fechas quedan desordenadas y no consecutivas.
   - estado: 80% Completada, 10% En proceso y 10% Cancelada.
   - id_medio_pago e id_persona: dentro del rango de los datos de prueba. */

DECLARE @total INT = 1000000;
DECLARE @tamano_lote INT = 100000;
DECLARE @desde INT = 1;
DECLARE @hasta INT;
DECLARE @marca DATETIME2;
DECLARE @inicio DATETIME2 = SYSDATETIME();

WHILE @desde <= @total
BEGIN
    SET @hasta = @desde + @tamano_lote - 1;
    SET @marca = SYSDATETIME();

    INSERT INTO dbo.venta_historica WITH (TABLOCK) (
        fecha_venta,
        monto_total,
        estado,
        actualizado_en,
        id_medio_pago,
        id_persona
    )
    SELECT
        f.fecha_venta,
        f.monto_total,
        f.estado,
        CASE WHEN f.estado = 'Completada'
             THEN DATEADD(MINUTE, f.n % 120, f.fecha_venta)
        END,
        (f.n % 14) + 1,
        (f.n % 8) + 1
    FROM (
        SELECT
            n,
            DATEADD(SECOND,
                    CAST((CAST(n AS BIGINT) * 337) % 94608000 AS INT),
                    CONVERT(DATETIME, '2023-10-01')) AS fecha_venta,
            CAST((CAST(n AS BIGINT) * 7919) % 500000 / 100.0 + 500 AS DECIMAL(12,2)) AS monto_total,
            CASE
                WHEN n % 10 < 8 THEN 'Completada'
                WHEN n % 10 = 8 THEN 'En proceso'
                ELSE 'Cancelada'
            END AS estado
        FROM dbo.numeros
        WHERE n BETWEEN @desde AND @hasta
    ) AS f;

    PRINT 'Lote ' + CAST(@desde AS VARCHAR(10)) + ' a ' + CAST(@hasta AS VARCHAR(10)) + ': '
        + CAST(DATEDIFF(MILLISECOND, @marca, SYSDATETIME()) AS VARCHAR(20)) + ' ms';

    SET @desde = @hasta + 1;
END;

PRINT 'Carga terminada en ' + CAST(DATEDIFF(SECOND, @inicio, SYSDATETIME()) AS VARCHAR(20)) + ' segundos.';
GO


-- Verificacion de filas, rango de fechas y objetos que hoy tiene la tabla

SELECT COUNT(*) AS filas_totales FROM dbo.venta_historica;
GO

SELECT
    MIN(fecha_venta) AS primera_fecha,
    MAX(fecha_venta) AS ultima_fecha
FROM dbo.venta_historica;
GO

-- Filas del periodo que se consulta en todas las pruebas
SELECT COUNT(*) AS filas_del_periodo
FROM dbo.venta_historica
WHERE fecha_venta >= '2026-03-02'
  AND fecha_venta <  '2026-03-09';
GO

-- Tiene que devolver solo el heap (sin indice agrupado ni no agrupado)
SELECT name AS indice, type_desc AS tipo
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.venta_historica');
GO

EXEC sp_spaceused 'dbo.venta_historica';
GO
