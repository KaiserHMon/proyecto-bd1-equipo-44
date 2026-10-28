-- Usar la base de datos supermercado_db
USE supermercado_db;

-- Modificar producto recién insertado mediante el procedimiento almacenado sp_ModificarProducto
EXEC sp_ModificarProducto
    @id_producto = 7,
    @nombre = 'Aceite de Girasol Especial 900ml',
    @precio = 1750.00,
    @stock = 95,
    @peso = 0.90,
    @descripcion = 'Aceite puro de girasol refinado doble filtrado',
    @id_categoria = 3,
    @id_unidad_medida = 9;

-- Dar de baja (borrado lógico) mediante el procedimiento (en este caso el producto con ID 8)
EXEC sp_BorrarProductoLogico @id_producto = 8;


