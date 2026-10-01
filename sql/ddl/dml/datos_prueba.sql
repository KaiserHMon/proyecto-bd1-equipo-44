USE supermercado_db;

/* ============================================================
   Nota 1: 'actualizado_en' y 'eliminado_en' no se cargan en el
   poblado inicial. Son columnas nullables sin DEFAULT: quedan en
   NULL hasta que ocurra un UPDATE o un borrado logico. La unica
   excepcion es 'venta', donde el estado paso de 'En proceso' a
   'Finalizada', o sea que la fila si fue modificada.
 
   Nota 2: 'tarjeta' es una especializacion de 'medio_de_pago' con
   PK = FK, asi que cada tarjeta ocupa una fila de medio_de_pago.
   Con 5 registros por tabla, las 5 son tarjetas. Al ampliar a
   8-10 conviene sumar una fila 'Efectivo' sin tarjeta asociada.
   ============================================================ */
 
 
-- ============================================================
-- 1. TABLAS INDEPENDIENTES
-- ============================================================
 
INSERT INTO rol (nombre, creado_en) VALUES
('Administrador',      '2026-01-10 09:00:00'),
('Cajero',             '2026-01-10 09:00:00'),
('Inventario',         '2026-01-10 09:00:00'),
('Supervisor de caja', '2026-01-10 09:00:00'),
('Auditor',            '2026-01-10 09:00:00');

--INSERCIONES UTILIZANDO EL VALOR DEFAULT EN creado_en
INSERT INTO rol (nombre) VALUES
('Supervisor de inventario'),
('Gerente de Sucursal'),
('Repositor');

INSERT INTO persona (nombre, apellido, email, creado_en) VALUES
('Lucia',    'Gomez',    'lucia.gomez@supermercado.com.ar',     '2026-01-12 08:30:00'),
('Martin',   'Ferreyra', 'martin.ferreyra@supermercado.com.ar', '2026-01-12 08:35:00'),
('Ana',      'Beltran',  'ana.beltran@supermercado.com.ar',     '2026-01-12 08:40:00'),
('Diego',    'Sosa',     'diego.sosa@supermercado.com.ar',      '2026-01-13 10:15:00'),
('Carolina', 'Mendez',   'carolina.mendez@supermercado.com.ar', '2026-01-13 10:20:00'),
-- INSERCION PARA PROBAR SI LA RESTRICCIÓN CHECK EN EMAIL FUNCIONA CORRECTAMENTE
('Lucio', 'Voreno',   'lucio_vo.reno@.com.ar', '2026-01-13 10:20:00'),
('Flavio', 'Vespasiano',   'flavio_vespa@supermercado.com.ar', '2026-01-13 10:20:00');

--INSERCION UTILIZANDO EL VALOR DEFAULT EN creado_en
INSERT INTO persona (nombre, apellido, email) VALUES
('Julio Cesar', 'Gonzales',   'jcgonzales@supermercado.com.ar');

-- INSERCION PARA PROBAR SI LA RESTRICCIÓN CHECK DEL @ EN EMAIL FUNCIONA CORRECTAMENTE, COMENTAR O ELIMINAR ANTES DE EJECUTAR TODA LA CONSULTA
-- INSERT INTO persona (nombre, apellido, email) VALUES
-- ('Augusto', 'Octaviano',   'imperator_augusto.com.ar');
 
INSERT INTO categoria (nombre, descripcion, creado_en) VALUES
('Lacteos',   'Leches, quesos, yogures y derivados refrigerados.',       '2026-01-15 09:00:00'),
('Bebidas',   'Gaseosas, aguas, jugos y bebidas sin alcohol.',           '2026-01-15 09:05:00'),
('Almacen',   'Productos secos de despensa: arroz, fideos, harinas.',    '2026-01-15 09:10:00'),
('Limpieza',  'Articulos de limpieza del hogar y detergentes.',          '2026-01-15 09:15:00'),
('Panaderia', 'Pan fresco, facturas y productos de elaboracion propia.', '2026-01-15 09:20:00');
--INSERCION UTILIZANDO EL VALOR DEFAULT EN creado_en
INSERT INTO categoria (nombre, descripcion) VALUES
('Carniceria', 'Cortes de carne, pollo y embutidos'),
('Conservas', 'Latas de comida de todo tipo'),
('Congelados', 'Pescado, verduras, helados y variedad');
 
INSERT INTO unidad_medida (nombre, abreviatura) VALUES
('Unidad',    'un'),
('Kilogramo', 'kg'),
('Gramo',     'g'),
('Litro',     'l'),
('Mililitro', 'ml'),
('Docena',    'doc'),
('Paquete',   'paq'),
('Caja',      'cj'),
('Botella',   'bot'),
('Lata',      'lat');
 
INSERT INTO medio_de_pago (tipo, creado_en) VALUES
('Tarjeta',  '2026-01-16 08:10:00'),
('Tarjeta', '2026-01-16 08:05:00'),
('Tarjeta', '2026-01-16 08:10:00'),
('Tarjeta', '2026-01-16 08:15:00'),
('Tarjeta', '2026-01-16 08:20:00'),
('Tarjeta', '2026-01-16 08:25:00'),
('Tarjeta', '2026-01-16 08:25:00'),
('Transferencia', '2026-01-16 08:15:00'),
('Efectivo',  '2026-01-16 08:20:00'),
('QR', '2026-01-16 08:25:00');

--INSERCION UTILIZANDO EL VALOR DEFAULT EN creado_en
INSERT INTO medio_de_pago (tipo) VALUES
('Tarjeta'),
('Transferencia'),
('Efectivo'),
('QR');

--INSERCION UTILIZANDO UN VALOR PARA tipo FUERA DE LOS DEFINIDOS, DEBE FALLAR, COMENTAR O ELIMINAR ANTES DE EJECUTAR TODO EL PROYECTO
--INSERT INTO medio_de_pago (tipo, creado_en) VALUES
--('Tarjeta de credito',  '2026-01-16 08:10:00');
 
INSERT INTO banco (nombre) VALUES
('Banco de la Nacion Argentina'),
('Banco Galicia'),
('Banco Santander Argentina'),
('BBVA Argentina'),
('Banco Macro'),
('Banco de Corrientes'),
('Banco Entre Rios'),
('Banco HSBC');
 
-- ============================================================
-- 2. TABLAS DEPENDIENTES
-- ============================================================
 
/* La contrasena se escribe en claro y la hashea el motor con HASHBYTES.
   CONVERT(..., 2) devuelve el hash como texto hexadecimal de 64 caracteres,
   para que entre en la columna VARCHAR(255).
   Credenciales de prueba: lgomez/Admin123 - mferreyra/Cajero123 -
   abeltran/Cajero456 - dsosa/Invent123 - cmendez/Super123
 
   codigo_autorizacion: solo lo tiene el supervisor de caja. Es la clave
   que habilita la anulacion de una venta; el resto de los usuarios va
   en NULL porque no pueden autorizar esa operacion.
   Codigo del supervisor cmendez: 4821                              */

INSERT INTO usuario (id_persona, nombre_usuario, password, codigo_autorizacion, creado_en, id_rol) VALUES
(1, 'lgomez',    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin123'),  2), NULL,   '2026-01-12 08:45:00', 1),
(2, 'mferreyra', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Cajero123'), 2), NULL,   '2026-01-12 08:50:00', 2),
(3, 'abeltran',  CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Cajero456'), 2), NULL,   '2026-01-12 08:55:00', 2),
(4, 'dsosa',     CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Invent123'), 2), NULL,   '2026-01-13 10:30:00', 3),
(5, 'cmendez',   CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Super123'),  2), '4821', '2026-01-13 10:35:00', 4);

--INSERCION UTILIZANDO EL VALOR DEFAULT EN creado_en
INSERT INTO usuario (id_persona, nombre_usuario, password, codigo_autorizacion, id_rol) VALUES
(6, 'lvoreno',   CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Super123'),  2), '8476', 6),
(7, 'vespa_siano',   CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Gerente123'),  2), '8616', 7);

--INSERCION UTILIZANDO rol distinto PARA MISMA persona, DEBE FALLAR POR id_usuario Y POR nombre_usuario, COMENTAR O ELIMINAR ANTES DE EJECUTAR LA CONSULTA
--INSERT INTO usuario (id_persona, nombre_usuario, password, codigo_autorizacion, creado_en, id_rol) VALUES
--(1, 'lgomez',    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Cajero123'),  2), NULL,   '2026-01-12 08:45:00', 2);
 
INSERT INTO producto (nombre, precio, stock, peso, codigo_barra, descripcion, creado_en, id_categoria, id_unidad_medida) VALUES
('Leche entera sachet 1 L',   1250.00, 120, 1.03, '7790001000015', 'Leche entera pasteurizada en sachet de 1 litro.',      '2026-01-20 09:00:00', 1, 4),
('Gaseosa cola 2.25 L',       3200.00,  80, 2.35, '7790002000022', 'Gaseosa sabor lima limon en botella descartable de 2.25 L.', '2026-01-20 09:05:00', 2, 4),
('Arroz largo fino 1 kg',     1890.00, 150, 1.00, '7790003000039', 'Arroz largo fino arcor, paquete de 1 kg.',    '2026-01-20 09:10:00', 3, 2),
('Detergente liquido 750 ml', 2450.00,  60, 0.80, '7790004000046', 'Detergente concentrado para vajilla, botella 750 ml.', '2026-01-20 09:15:00', 4, 5),
('Pan frances por kilo',      2900.00,  40, 1.00, '7790005000053', 'Pan frances de elaboracion propia, vendido por kilo.', '2026-01-20 09:20:00', 5, 2),
('Latas de atun',             2750.00,  40, 0.17, '7790007000077', 'Atun al natural en lata de 170 g.', '2026-01-20 09:25:00', 7, 10);

--INSERCION PROBANDO LA CONDICION UNIQUE DE codigo_bara, DEBE FALLAR
--INSERT INTO producto (nombre, precio, stock, peso, codigo_barra, descripcion, id_categoria, id_unidad_medida) VALUES
--('Test codigo repetido', 100.00, 10, 1.00, '7790001000015', 'Prueba codigo de barra duplicado.', 1, 1);

--INSERCION PROBANDO LA FK de id_categoria, DEBE FALLAR
--INSERT INTO producto (nombre, precio, stock, peso, codigo_barra, descripcion, id_categoria, id_unidad_medida) VALUES
--('Test categoria', 100.00, 10, 1.00, 'T-0006', 'Prueba FK categoria.', 99, 1);

INSERT INTO tarjeta (id_medio_pago, tipo_tarjeta, marca_tarjeta, numero_tarjeta, fecha_vencimiento, creado_en, id_banco) VALUES
(1, 'Credito', 'Visa',             '4111111111111111', '2028-09-30', '2026-01-16 08:05:00', 1),
(2, 'Debito',  'Mastercard',       '5555555555554444', '2027-06-30', '2026-01-16 08:10:00', 2),
(3, 'Credito', 'Mastercard',       '5105105105105100', '2029-03-31', '2026-01-16 08:15:00', 3),
(4, 'Debito',  'Visa',             '4012888888881881', '2028-12-31', '2026-01-16 08:20:00', 4),
(5, 'Credito', 'American Express', '378282246310005',  '2027-11-30', '2026-01-16 08:25:00', 5),
(6, 'Debito', 'American Express', '378482247310005',  '2027-11-30', '2026-01-16 08:25:00', 5);

--INSERCION UTILIZANDO EL VALOR DEFAULT EN creado_en

INSERT INTO tarjeta (id_medio_pago, tipo_tarjeta, marca_tarjeta, numero_tarjeta, fecha_vencimiento,id_banco) VALUES
(7, 'Credito', 'Visa', '379283246312215',  '2027-11-30', 8),
(11, 'Debito', 'UALA', '374282746311005',  '2027-11-30', 8);
 
/* Unica tabla con 'actualizado_en' cargado: la venta nace 'En proceso' y
   al cobrarse pasa a 'Finalizada', o sea que la fila fue modificada.
   La venta 5 sigue en proceso, por eso queda en NULL.
   monto_total coincide con la suma de los subtotales del detalle.      */

INSERT INTO venta (monto_total, estado, creado_en, actualizado_en, id_medio_pago, id_persona) VALUES
(3780.00, 'Completada', '2026-02-02 10:12:00', '2026-02-02 10:13:00', 1, 2),
(7500.00, 'Completada', '2026-02-02 11:40:00', '2026-02-02 11:41:00', 2, 2),
(9600.00, 'Completada', '2026-02-03 09:25:00', '2026-02-03 09:26:00', 10, 3),
(4900.00, 'Completada', '2026-02-03 18:05:00', '2026-02-03 18:06:00', 4, 3),
(2900.00, 'En proceso', '2026-02-04 08:50:00', NULL,                  5, 2),
(6900.00, 'Completada', '2026-02-08 16:25:00', '2026-02-08 18:06:00', 4, 4),
(2900.00, 'En proceso', '2026-02-04 08:50:00', NULL,                  12, 3);

--INSERCION PROBANDO EL CHECK DE MONTO, DEBE FALLAR
--(0, 'Completada', '2026-02-03 09:25:00', '2026-02-03 09:26:00', 3, 3),

INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal, creado_en) VALUES
(1, 3, 2, 1890.00, 3780.00, '2026-02-02 10:12:00'),
(2, 1, 6, 1250.00, 7500.00, '2026-02-02 11:40:00'),
(3, 2, 3, 3200.00, 9600.00, '2026-02-03 09:25:00'),
(4, 4, 2, 2450.00, 4900.00, '2026-02-03 18:05:00'),
(5, 5, 1, 2900.00, 2900.00, '2026-02-04 08:50:00');

--INSERCION PROBANDO EL CHECK DE CANTIDAD, DEBE FALLAR
--INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal, creado_en) VALUES
--(1, 1, 0, 1250.00, 0.00, '2026-02-02 10:12:00');

--INSERCION PROBANDO LA FK DE id_venta (VENTA INEXISTENTE), DEBE FALLAR
--INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal, creado_en) VALUES
--(99, 1, 1, 1250.00, 1250.00, '2026-02-02 10:12:00');

--INSERCION PROBANDO LA PK COMPUESTA (PRODUCTO REPETIDO EN LA MISMA VENTA), DEBE FALLAR
--INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal, creado_en) VALUES
--(2, 1, 1, 1250.00, 1250.00, '2026-02-02 11:40:00');