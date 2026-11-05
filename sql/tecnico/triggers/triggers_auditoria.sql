-- Trigger de auditoria que se ejecuta cuando se actualiza una venta

CREATE TRIGGER dbo.auditoria_venta_update
ON dbo.venta
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.auditoria_venta (
        id_venta,
        monto_total,
        estado,
        creado_en,
        actualizado_en,
        id_medio_pago,
        id_persona,
        fecha_auditoria,
        usuario_bd
    )
    SELECT
        d.id_venta,
        d.monto_total,
        d.estado,
        d.creado_en,
        d.actualizado_en,
        d.id_medio_pago,
        d.id_persona,
        SYSDATETIME(),
        USER_NAME()
    FROM deleted AS d;
END;
GO


-- Trigger de auditoria que se ejecuta cuando se elimina un producto

CREATE TRIGGER dbo.auditoria_producto_delete
ON dbo.producto
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.auditoria_producto (
        id_producto,
        nombre,
        precio,
        stock,
        peso,
        codigo_barra,
        descripcion,
        creado_en,
        actualizado_en,
        eliminado_en,
        id_categoria,
        id_unidad_medida,
        fecha_auditoria,
        usuario_bd
    )
    SELECT
        d.id_producto,
        d.nombre,
        d.precio,
        d.stock,
        d.peso,
        d.codigo_barra,
        d.descripcion,
        d.creado_en,
        d.actualizado_en,
        d.eliminado_en,
        d.id_categoria,
        d.id_unidad_medida,
        SYSDATETIME(),
        USER_NAME()
    FROM deleted AS d;
END;
GO


-- Ejemplo para probar el trigger de actualizacion de venta

-- 1. Consultar la venta original
SELECT *
FROM dbo.venta
WHERE id_venta = 1;

-- 2. Actualizar la venta
UPDATE dbo.venta
SET estado = 'Completada',
    monto_total = monto_total + 1000
WHERE id_venta = 1;

-- 3. Consultar la venta modificada
SELECT *
FROM dbo.venta
WHERE id_venta = 1;

-- 4. Consultar la auditoría
SELECT *
FROM dbo.auditoria_venta
WHERE id_venta = 1
ORDER BY fecha_auditoria DESC;


-- Ejemplo para probar trigger del delete de producto

-- 1. Consultar el producto original
SELECT *
FROM dbo.producto
WHERE id_producto = 6;

-- 2. Eliminar el producto
DELETE FROM dbo.producto
WHERE id_producto = 6;

-- 3. Comprobar que ya no existe
SELECT *
FROM dbo.producto
WHERE id_producto = 6;

-- 4. Consultar la auditoría
SELECT *
FROM dbo.auditoria_producto
WHERE id_producto = 6
ORDER BY fecha_auditoria DESC;
