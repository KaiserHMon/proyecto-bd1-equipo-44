-- Usar la base de datos supermercado_db
USE supermercado_db;

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS PARA LA TABLA: producto
-- ============================================================
CREATE OR ALTER PROCEDURE sp_InsertarProducto
    @nombre VARCHAR(150),
    @precio DECIMAL(10,2),
    @stock INT,
    @peso DECIMAL(10,2),
    @codigo_barra VARCHAR(50),
    @descripcion TEXT,
    @id_categoria INT,
    @id_unidad_medida INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO producto (nombre, precio, stock, peso, codigo_barra, descripcion, id_categoria, id_unidad_medida)
        VALUES (@nombre, @precio, @stock, @peso, @codigo_barra, @descripcion, @id_categoria, @id_unidad_medida);
        
        PRINT 'Producto insertado con éxito.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;


-- Procedimiento para MODIFICAR un producto
CREATE OR ALTER PROCEDURE sp_ModificarProducto
    @id_producto INT,
    @nombre VARCHAR(150),
    @precio DECIMAL(10,2),
    @stock INT,
    @peso DECIMAL(10,2),
    @descripcion TEXT,
    @id_categoria INT,
    @id_unidad_medida INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE producto
        SET nombre = @nombre,
            precio = @precio,
            stock = @stock,
            peso = @peso,
            descripcion = @descripcion,
            id_categoria = @id_categoria,
            id_unidad_medida = @id_unidad_medida,
            actualizado_en = CURRENT_TIMESTAMP
        WHERE id_producto = @id_producto AND eliminado_en IS NULL;

        PRINT 'Producto modificado con éxito.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;

-- Procedimiento para BORRAR un producto (Borrado Lógico)
CREATE OR ALTER PROCEDURE sp_BorrarProductoLogico
    @id_producto INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE producto
        SET eliminado_en = CURRENT_TIMESTAMP
        WHERE id_producto = @id_producto AND eliminado_en IS NULL;

        PRINT 'Producto dado de baja lógicamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;


-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS PARA LA TABLA: categoria
-- ============================================================

-- Insertar una nueva categoría
CREATE OR ALTER PROCEDURE sp_InsertarCategoria
    @nombre VARCHAR(100),
    @descripcion TEXT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO categoria (nombre, descripcion)
        VALUES (@nombre, @descripcion);

        PRINT 'Categoría insertada con éxito.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;


-- Modificar una categoría existente
CREATE OR ALTER PROCEDURE sp_ModificarCategoria
    @id_categoria INT,
    @nombre VARCHAR(100),
    @descripcion TEXT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE categoria
        SET nombre = @nombre,
            descripcion = @descripcion,
            actualizado_en = CURRENT_TIMESTAMP
        WHERE id_categoria = @id_categoria 
          AND eliminado_en IS NULL;

        IF @@ROWCOUNT = 0
            PRINT 'No se encontró la categoría activa con el ID especificado.';
        ELSE
            PRINT 'Categoría modificada con éxito.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;


-- Borrado lógico de una categoría
CREATE OR ALTER PROCEDURE sp_BorrarCategoriaLogico
    @id_categoria INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar si tiene productos activos asociados antes de darla de baja
        IF EXISTS (SELECT 1 FROM producto WHERE id_categoria = @id_categoria AND eliminado_en IS NULL)
        BEGIN
            RAISERROR('No se puede dar de baja la categoría porque tiene productos activos asociados.', 16, 1);
            RETURN;
        END

        UPDATE categoria
        SET eliminado_en = CURRENT_TIMESTAMP
        WHERE id_categoria = @id_categoria 
          AND eliminado_en IS NULL;

        IF @@ROWCOUNT = 0
            PRINT 'No se encontró la categoría activa con el ID especificado.';
        ELSE
            PRINT 'Categoría dada de baja lógicamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;

