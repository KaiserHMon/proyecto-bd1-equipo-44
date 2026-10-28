-- Usar la base de datos supermercado_db
USE supermercado_db;


-- Función Escalar: Calcula el precio con IVA (21%) de un producto
CREATE OR ALTER FUNCTION fn_CalcularPrecioConIVA (@precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN ROUND(@precio * 1.21, 2);
END;


-- Función Escalar: Obtiene el total gastado histórico por una persona
CREATE OR ALTER FUNCTION fn_TotalGastadoPorPersona (@id_persona INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @total DECIMAL(12,2);
    
    SELECT @total = ISNULL(SUM(monto_total), 0.00)
    FROM venta
    WHERE id_persona = @id_persona AND estado = 'Completada';
    
    RETURN @total;
END;


-- Función de Tabla en Línea: Devuelve los productos activos por categoría
CREATE OR ALTER FUNCTION fn_ListarProductosPorCategoria (@id_categoria INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.id_producto,
        p.nombre,
        p.precio,
        p.stock,
        p.codigo_barra,
        c.nombre AS categoria,
        u.abreviatura AS unidad
    FROM producto p
    INNER JOIN categoria c ON p.id_categoria = c.id_categoria
    INNER JOIN unidad_medida u ON p.id_unidad_medida = u.id_unidad_medida
    WHERE p.id_categoria = @id_categoria 
      AND p.eliminado_en IS NULL
);

-- Pruebas de las funciones
-- Uso de fn_CalcularPrecioConIVA
SELECT id_producto, nombre, precio AS precio_base, dbo.fn_CalcularPrecioConIVA(precio) AS precio_con_iva 
FROM producto;

-- Uso de fn_TotalGastadoPorPersona
SELECT id_persona, nombre, apellido, dbo.fn_TotalGastadoPorPersona(id_persona) AS total_compras
FROM persona;

-- Uso de fn_ListarProductosPorCategoria
SELECT * FROM dbo.fn_ListarProductosPorCategoria(3);
