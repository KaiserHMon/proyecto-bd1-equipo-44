-- Creacion de la base de datos

CREATE DATABASE supermercado_db;

-- Seleccionar la base de datos recién creada
USE supermercado_db;


-- 1. Tablas Independientes

CREATE TABLE rol (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    eliminado_en DATETIME NULL,
    CONSTRAINT CK_rol_fechas CHECK (eliminado_en IS NULL OR eliminado_en >= creado_en)
);

CREATE TABLE persona (
    id_persona INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actualizado_en DATETIME NULL,
    eliminado_en DATETIME NULL,
    CONSTRAINT CK_persona_email CHECK (email LIKE '%@%._%'),
    CONSTRAINT CK_persona_fechas CHECK (eliminado_en IS NULL OR eliminado_en >= creado_en)
);

CREATE TABLE categoria (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actualizado_en DATETIME NULL,
    eliminado_en DATETIME NULL,
    CONSTRAINT CK_categoria_fechas CHECK (eliminado_en IS NULL OR eliminado_en >= creado_en)
);

CREATE TABLE unidad_medida (
    id_unidad_medida INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    abreviatura VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE medio_de_pago (
    id_medio_pago INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    eliminado_en DATETIME NULL,
    CONSTRAINT CK_medio_pago_tipo CHECK (tipo IN ('Efectivo', 'Tarjeta', 'Transferencia', 'QR', 'Otro')),
    CONSTRAINT CK_mediopago_fechas CHECK (eliminado_en IS NULL OR eliminado_en >= creado_en)
);

CREATE TABLE banco (
    id_banco INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Tablas Dependientes

CREATE TABLE usuario (
    id_persona INT PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    codigo_autorizacion VARCHAR(100) NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actualizado_en DATETIME NULL,
    eliminado_en DATETIME NULL,
    id_rol INT NOT NULL,
    CONSTRAINT CK_usuario_fechas CHECK (eliminado_en IS NULL OR eliminado_en >= creado_en),
    CONSTRAINT FK_usuario_persona FOREIGN KEY (id_persona) REFERENCES persona(id_persona),
    CONSTRAINT FK_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
);

CREATE TABLE producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    peso DECIMAL(10,2) NULL,
    codigo_barra VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actualizado_en DATETIME NULL,
    eliminado_en DATETIME NULL,
    id_categoria INT NOT NULL,
    id_unidad_medida INT NOT NULL,
    CONSTRAINT CK_producto_precio CHECK (precio > 0),
    CONSTRAINT CK_producto_stock CHECK (stock >= 0),
    CONSTRAINT CK_producto_peso CHECK (peso IS NULL OR peso > 0),
    CONSTRAINT CK_producto_fechas CHECK (eliminado_en IS NULL OR eliminado_en >= creado_en),
    CONSTRAINT FK_producto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    CONSTRAINT FK_producto_unidad_medida FOREIGN KEY (id_unidad_medida) REFERENCES unidad_medida(id_unidad_medida)
);

CREATE TABLE tarjeta (
    id_medio_pago INT PRIMARY KEY,
    tipo_tarjeta VARCHAR(50) NOT NULL,
    marca_tarjeta VARCHAR(50) NOT NULL,
    numero_tarjeta VARCHAR(20) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_banco INT NOT NULL,
    CONSTRAINT CK_tarjeta_tipo CHECK (tipo_tarjeta IN ('Debito', 'Credito', 'Prepaga')),
    CONSTRAINT FK_tarjeta_medio_pago FOREIGN KEY (id_medio_pago) REFERENCES medio_de_pago(id_medio_pago),
    CONSTRAINT FK_tarjeta_banco FOREIGN KEY (id_banco) REFERENCES banco(id_banco)
);

CREATE TABLE venta (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    monto_total DECIMAL(12,2) NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'En proceso',
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actualizado_en DATETIME NULL,
    id_medio_pago INT NOT NULL,
    id_persona INT NOT NULL,
    CONSTRAINT CK_venta_monto CHECK (monto_total >= 0),
    CONSTRAINT CK_venta_estado CHECK (estado IN ('En proceso', 'Completada', 'Cancelada')),
    CONSTRAINT FK_venta_medio_pago FOREIGN KEY (id_medio_pago) REFERENCES medio_de_pago(id_medio_pago),
    CONSTRAINT FK_venta_persona FOREIGN KEY (id_persona) REFERENCES persona(id_persona)
);

CREATE TABLE detalle_venta (
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_venta_producto PRIMARY KEY (id_venta, id_producto),
    CONSTRAINT CK_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT CK_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT FK_detalle_venta FOREIGN KEY (id_venta) REFERENCES venta(id_venta),
    CONSTRAINT FK_detalle_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);