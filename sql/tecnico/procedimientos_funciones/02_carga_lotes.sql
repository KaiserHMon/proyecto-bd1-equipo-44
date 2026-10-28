-- Usar la base de datos supermercado_db
USE supermercado_db;

-- Inserción de lote de datos con sentencias INSERT directas
INSERT INTO producto (nombre, precio, stock, peso, codigo_barra, descripcion, id_categoria, id_unidad_medida) VALUES
('Aceite de Girasol 900ml', 1650.00, 100, 0.90, '7790008000084', 'Aceite puro de girasol refinado', 3, 9),
('Yerba Mate 1kg', 3400.00, 80, 1.00, '7790009000091', 'Yerba con palo tradicional', 3, 2),
('Yogur Bebible Frutilla 1L', 1980.00, 50, 1.02, '7790010000107', 'Yogur bebible parcialmente descremado', 1, 4);

-- Inserción utilizando los procedimientos almacenados
EXEC sp_InsertarProducto 
    @nombre = 'Galletitas de Agua 300g', 
    @precio = 1100.00, 
    @stock = 120, 
    @peso = 0.30, 
    @codigo_barra = '7790011000114', 
    @descripcion = 'Pack x3 galletitas crackers de agua', 
    @id_categoria = 3, 
    @id_unidad_medida = 7;

EXEC sp_InsertarProducto 
    @nombre = 'Lavandina Clásica 1L', 
    @precio = 1200.00, 
    @stock = 90, 
    @peso = 1.05, 
    @codigo_barra = '7790012000121', 
    @descripcion = 'Lavandina común desinfectante', 
    @id_categoria = 4, 
    @id_unidad_medida = 9;

EXEC sp_InsertarProducto 
    @nombre = 'Agua Mineral Sin Gas 2L', 
    @precio = 1450.00, 
    @stock = 110, 
    @peso = 2.00, 
    @codigo_barra = '7790013000138', 
    @descripcion = 'Agua mineral natural de manantial', 
    @id_categoria = 2, 
    @id_unidad_medida = 9;

