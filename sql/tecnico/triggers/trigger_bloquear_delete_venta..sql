CREATE TRIGGER trg_bloquear_delete_venta
ON venta
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    RAISERROR ('Operación denegada: No está permitido eliminar registros de la tabla VENTA por integridad histórica y contable. Utilice el campo "estado" para anularla.', 16, 1);
END;
GO
