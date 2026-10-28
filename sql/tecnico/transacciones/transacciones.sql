/* ============================================================================
   MANEJO DE TRANSACCIONES

   Objetivo:
   Registrar una venta completa como una sola unidad de trabajo: encabezado,
   detalle y descuento de stock. Si algo falla, ROLLBACK deshace todos los
   cambios para evitar ventas incompletas o descuentos parciales.
   ============================================================================ */

USE supermercado_db;
GO

SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------------
   1. Tipo de tabla para recibir todos los productos de una venta.
      La PK evita repetir el mismo producto en el mismo detalle, respetando la
      clave primaria compuesta de detalle_venta (id_venta, id_producto).
   --------------------------------------------------------------------------- */
IF TYPE_ID(N'dbo.DetalleVentaTransaccional') IS NULL
BEGIN
    EXEC(N'
        CREATE TYPE dbo.DetalleVentaTransaccional AS TABLE
        (
            id_producto INT NOT NULL PRIMARY KEY,
            cantidad INT NOT NULL
        );
    ');
END;
GO

/* ---------------------------------------------------------------------------
   2. Procedimiento transaccional para registrar una venta:
      - Comprueba los datos principales y los productos solicitados.
      - Bloquea los productos consultados durante la transaccion para reducir el riesgo de que dos cajas vendan simultaneamente el mismo stock.
      - Inserta encabezado y detalle, guardando el precio historico.
      - Descuenta stock solo si alcanza para cada producto.
      - Si no se puede descontar todo el stock solicitado, lanza un error y el bloque CATCH revierte encabezado, detalles y cualquier descuento.
   --------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarVentaTransaccional
    @id_persona INT,
    @id_medio_pago INT,
    @detalles dbo.DetalleVentaTransaccional READONLY,
    @id_venta INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @monto_total DECIMAL(12,2);
    DECLARE @cantidad_detalles INT;
    DECLARE @filas_stock_actualizadas INT;

    SET @id_venta = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Una venta debe tener al menos un producto y cantidades positivas.
        IF NOT EXISTS (SELECT 1 FROM @detalles)
        BEGIN
            THROW 50001, N'La venta debe incluir al menos un producto.', 1;
        END;

        IF EXISTS (SELECT 1 FROM @detalles WHERE cantidad <= 0)
        BEGIN
            THROW 50002, N'Todas las cantidades deben ser mayores que cero.', 1;
        END;

        -- Comprueba que la persona y el medio de pago existan y esten activos.
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.persona
            WHERE id_persona = @id_persona
              AND eliminado_en IS NULL
        )
        BEGIN
            THROW 50003, N'La persona indicada no existe o esta dada de baja.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.medio_de_pago
            WHERE id_medio_pago = @id_medio_pago
              AND eliminado_en IS NULL
        )
        BEGIN
            THROW 50004, N'El medio de pago indicado no existe o esta dado de baja.', 1;
        END;

        -- Verifica que todos los productos existan y esten activos.
        -- UPDLOCK y HOLDLOCK mantienen bloqueos hasta finalizar la transaccion, evitando que otra operacion cambie simultaneamente esos registros.
        IF EXISTS
        (
            SELECT 1
            FROM @detalles AS d
            LEFT JOIN dbo.producto AS p WITH (UPDLOCK, HOLDLOCK)
                ON p.id_producto = d.id_producto
            WHERE p.id_producto IS NULL
               OR p.eliminado_en IS NOT NULL
        )
        BEGIN
            THROW 50005, N'Hay productos inexistentes o dados de baja en el detalle.', 1;
        END;

        -- Calcula el total con los precios vigentes de la tabla producto.
        SELECT @monto_total = SUM(CONVERT(DECIMAL(12,2), p.precio * d.cantidad))
        FROM @detalles AS d
        INNER JOIN dbo.producto AS p
            ON p.id_producto = d.id_producto;

        -- Registra el encabezado de la venta dentro de la transaccion.
        INSERT INTO dbo.venta
        (
            monto_total,
            estado,
            creado_en,
            actualizado_en,
            id_medio_pago,
            id_persona
        )
        VALUES
        (
            @monto_total,
            'Completada',
            GETDATE(),
            GETDATE(),
            @id_medio_pago,
            @id_persona
        );

        SET @id_venta = CONVERT(INT, SCOPE_IDENTITY());

        -- Registra cada producto vendido y conserva su precio historico.
        INSERT INTO dbo.detalle_venta
        (
            id_venta,
            id_producto,
            cantidad,
            precio_unitario,
            subtotal,
            creado_en
        )
        SELECT
            @id_venta,
            d.id_producto,
            d.cantidad,
            p.precio,
            CONVERT(DECIMAL(12,2), p.precio * d.cantidad),
            GETDATE()
        FROM @detalles AS d
        INNER JOIN dbo.producto AS p
            ON p.id_producto = d.id_producto;

        -- Descuenta el stock solamente para productos con cantidad suficiente.
        -- Si al menos uno no alcanza, la cantidad de filas actualizadas sera menor que la cantidad de productos solicitados y se hara ROLLBACK.
        UPDATE p
        SET p.stock = p.stock - d.cantidad
        FROM dbo.producto AS p
        INNER JOIN @detalles AS d
            ON d.id_producto = p.id_producto
        WHERE p.stock >= d.cantidad
          AND p.eliminado_en IS NULL;

        SET @filas_stock_actualizadas = @@ROWCOUNT;
        SELECT @cantidad_detalles = COUNT(*) FROM @detalles;

        IF @filas_stock_actualizadas <> @cantidad_detalles
        BEGIN
            THROW 50006, N'Stock insuficiente para completar la venta. La operacion fue cancelada.', 1;
        END;

        -- COMMIT confirma juntos el encabezado, el detalle y la actualizacion del inventario. Ninguna parte se confirma por separado.
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- ROLLBACK deshace todos los cambios si ocurrio cualquier error.
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @id_venta = NULL;
        THROW;
    END CATCH;
END;
GO

/* ===========================================================================
   3. DEMOSTRACION 1: venta correcta con stock suficiente.
      En el archivo de datos de prueba, la leche cuesta $1.250 y el arroz $1.890.
      Se venden 2 leches y 1 arroz: total esperado $4.390.
   =========================================================================== */
DECLARE @IdPersonaCajero INT;
DECLARE @IdMedioPago INT;
DECLARE @IdLeche INT;
DECLARE @IdArroz INT;
DECLARE @VentaCorrecta INT;
DECLARE @DetallesCorrectos dbo.DetalleVentaTransaccional;

-- Busca registros por datos estables, sin depender directamente de sus IDENTITY.
SELECT TOP (1) @IdPersonaCajero = id_persona
FROM dbo.persona
WHERE email = 'martin.ferreyra@supermercado.com.ar'
  AND eliminado_en IS NULL;

SELECT TOP (1) @IdMedioPago = id_medio_pago
FROM dbo.medio_de_pago
WHERE tipo = 'Efectivo'
  AND eliminado_en IS NULL
ORDER BY id_medio_pago;

SELECT @IdLeche = id_producto
FROM dbo.producto
WHERE codigo_barra = '7790001000015'
  AND eliminado_en IS NULL;

SELECT @IdArroz = id_producto
FROM dbo.producto
WHERE codigo_barra = '7790003000039'
  AND eliminado_en IS NULL;

IF @IdPersonaCajero IS NULL OR @IdMedioPago IS NULL
   OR @IdLeche IS NULL OR @IdArroz IS NULL
BEGIN
    THROW 50100, N'No se encontraron los datos de prueba esperados. Revise las inserciones iniciales.', 1;
END;

INSERT INTO @DetallesCorrectos (id_producto, cantidad)
VALUES (@IdLeche, 2), (@IdArroz, 1);

EXEC dbo.sp_RegistrarVentaTransaccional
    @id_persona = @IdPersonaCajero,
    @id_medio_pago = @IdMedioPago,
    @detalles = @DetallesCorrectos,
    @id_venta = @VentaCorrecta OUTPUT;

PRINT N'PRUEBA A: venta registrada correctamente. Id de venta: '
    + CONVERT(NVARCHAR(20), @VentaCorrecta);

-- Resultado del encabezado de la nueva venta.
SELECT
    v.id_venta,
    v.estado,
    v.monto_total,
    v.creado_en,
    CONCAT(pe.nombre, ' ', pe.apellido) AS persona_asociada,
    mp.tipo AS medio_de_pago
FROM dbo.venta AS v
INNER JOIN dbo.persona AS pe ON pe.id_persona = v.id_persona
INNER JOIN dbo.medio_de_pago AS mp ON mp.id_medio_pago = v.id_medio_pago
WHERE v.id_venta = @VentaCorrecta;

-- Resultado del detalle: la columna precio_unitario guarda el precio historico.
SELECT
    dv.id_venta,
    p.nombre AS producto,
    dv.cantidad,
    dv.precio_unitario,
    dv.subtotal
FROM dbo.detalle_venta AS dv
INNER JOIN dbo.producto AS p ON p.id_producto = dv.id_producto
WHERE dv.id_venta = @VentaCorrecta;

-- El stock de la leche deberia bajar en 2 y el del arroz en 1.
SELECT id_producto, nombre, stock
FROM dbo.producto
WHERE id_producto IN (@IdLeche, @IdArroz)
ORDER BY id_producto;
GO

/* ===========================================================================
   4. DEMOSTRACION 2: venta rechazada por stock insuficiente.
      Solicita 1 leche (stock suficiente) y 9.999 arroces (stock insuficiente).
      El procedimiento puede alcanzar a insertar encabezado/detalle y descontar
      alguna linea; el error debe provocar ROLLBACK de TODA la operacion.
   =========================================================================== */
DECLARE @IdPersonaPrueba INT;
DECLARE @IdMedioPagoPrueba INT;
DECLARE @IdLechePrueba INT;
DECLARE @IdArrozPrueba INT;
DECLARE @VentaFallida INT;
DECLARE @DetallesInsuficientes dbo.DetalleVentaTransaccional;
DECLARE @VentasAntes INT;
DECLARE @DetallesAntes INT;
DECLARE @StockLecheAntes INT;
DECLARE @StockArrozAntes INT;

SELECT TOP (1) @IdPersonaPrueba = id_persona
FROM dbo.persona
WHERE email = 'martin.ferreyra@supermercado.com.ar'
  AND eliminado_en IS NULL;

SELECT TOP (1) @IdMedioPagoPrueba = id_medio_pago
FROM dbo.medio_de_pago
WHERE tipo = 'Efectivo'
  AND eliminado_en IS NULL
ORDER BY id_medio_pago;

SELECT @IdLechePrueba = id_producto
FROM dbo.producto
WHERE codigo_barra = '7790001000015'
  AND eliminado_en IS NULL;

SELECT @IdArrozPrueba = id_producto
FROM dbo.producto
WHERE codigo_barra = '7790003000039'
  AND eliminado_en IS NULL;

IF @IdPersonaPrueba IS NULL OR @IdMedioPagoPrueba IS NULL
   OR @IdLechePrueba IS NULL OR @IdArrozPrueba IS NULL
BEGIN
    THROW 50101, N'No se encontraron los datos necesarios para la prueba de stock insuficiente.', 1;
END;

-- Guarda el estado inicial que usaremos para comprobar la atomicidad.
SELECT @VentasAntes = COUNT(*) FROM dbo.venta;
SELECT @DetallesAntes = COUNT(*) FROM dbo.detalle_venta;
SELECT @StockLecheAntes = stock FROM dbo.producto WHERE id_producto = @IdLechePrueba;
SELECT @StockArrozAntes = stock FROM dbo.producto WHERE id_producto = @IdArrozPrueba;

INSERT INTO @DetallesInsuficientes (id_producto, cantidad)
VALUES (@IdLechePrueba, 1), (@IdArrozPrueba, 9999);

BEGIN TRY
    EXEC dbo.sp_RegistrarVentaTransaccional
        @id_persona = @IdPersonaPrueba,
        @id_medio_pago = @IdMedioPagoPrueba,
        @detalles = @DetallesInsuficientes,
        @id_venta = @VentaFallida OUTPUT;

    PRINT N'ATENCION: la prueba no era esperada; revise los valores de stock.';
END TRY
BEGIN CATCH
    PRINT N'PRUEBA B: se capturo el error esperado por stock insuficiente.';
    PRINT ERROR_MESSAGE();
END CATCH;

-- Los dos conteos deben arrojar cero registros agregados y el stock debe ser exactamente igual al guardado antes del intento fallido.
SELECT
    (SELECT COUNT(*) FROM dbo.venta) - @VentasAntes AS ventas_agregadas,
    (SELECT COUNT(*) FROM dbo.detalle_venta) - @DetallesAntes AS detalles_agregados,
    @StockLecheAntes AS stock_leche_antes,
    (SELECT stock FROM dbo.producto WHERE id_producto = @IdLechePrueba) AS stock_leche_despues,
    @StockArrozAntes AS stock_arroz_antes,
    (SELECT stock FROM dbo.producto WHERE id_producto = @IdArrozPrueba) AS stock_arroz_despues,
    CASE
        WHEN (SELECT COUNT(*) FROM dbo.venta) = @VentasAntes
         AND (SELECT COUNT(*) FROM dbo.detalle_venta) = @DetallesAntes
         AND (SELECT stock FROM dbo.producto WHERE id_producto = @IdLechePrueba) = @StockLecheAntes
         AND (SELECT stock FROM dbo.producto WHERE id_producto = @IdArrozPrueba) = @StockArrozAntes
        THEN N'CORRECTO: ROLLBACK completo, sin cambios parciales.'
        ELSE N'REVISAR: los datos cambiaron inesperadamente.'
    END AS resultado_verificacion;
GO
