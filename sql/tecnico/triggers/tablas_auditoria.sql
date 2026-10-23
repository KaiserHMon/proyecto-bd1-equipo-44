-- Tabla de auditoria para ventas

CREATE TABLE dbo.auditoria_venta (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,

    id_venta INT NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL,
    estado VARCHAR(30) NOT NULL,
    creado_en DATETIME NOT NULL,
    actualizado_en DATETIME NULL,
    id_medio_pago INT NOT NULL,
    id_persona INT NOT NULL,

    fecha_auditoria DATETIME2 NOT NULL,
    usuario_bd SYSNAME NOT NULL
);


-- Tabla de auditoria para productos

CREATE TABLE dbo.auditoria_producto (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,

    id_producto INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    peso DECIMAL(10,2) NULL,
    codigo_barra VARCHAR(50) NOT NULL,
    descripcion VARCHAR(MAX) NOT NULL,
    creado_en DATETIME NOT NULL,
    actualizado_en DATETIME NULL,
    eliminado_en DATETIME NULL,
    id_categoria INT NOT NULL,
    id_unidad_medida INT NOT NULL,

    fecha_auditoria DATETIME2 NOT NULL,
    usuario_bd SYSNAME NOT NULL
);