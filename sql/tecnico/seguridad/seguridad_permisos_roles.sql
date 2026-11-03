USE supermercado_db;

--ROLES

CREATE ROLE rol_cajero;
CREATE ROLE rol_inventario;
CREATE ROLE rol_administracion;
CREATE ROLE rol_supervisor;

--PERMISOS

--CAJERO: PUEDE REGISTRAR VENTA Y LECTURA MINIMA DE LA BASE, EL REGISTRAR VENTA SE HACE A TRAVES DEL SP
GRANT SELECT ON dbo.producto	   TO rol_cajero;
GRANT SELECT ON dbo.categoria      TO rol_cajero;
GRANT SELECT ON dbo.medio_de_pago  TO rol_cajero;

GRANT EXECUTE ON dbo.sp_RegistrarVentaTransaccional TO rol_cajero;
GRANT EXECUTE ON TYPE::dbo.DetalleVentaTransaccional TO rol_cajero;

--INVENTARIO: PUEDE VISUALIZAR, INSERTAR Y ACTUALIZAR EN EL CATALOGO COMPLETO DE LOS PRODUCTOS, PERO NO TIENE PERMISOS PARA HACER DELETE
GRANT SELECT, INSERT, UPDATE ON dbo.producto  TO rol_inventario;
GRANT SELECT, INSERT, UPDATE ON dbo.categoria TO rol_inventario;
GRANT SELECT ON dbo.unidad_medida             TO rol_inventario;

--ADMINISTRACION: PUEDE CREAR NUEVOS Y ACTUALIZAR USUARIOS Y CUENTAS DENTRO DE LA BASE, NO PUEDE VISUALIZAR LAS CONTRASEÑAS
GRANT SELECT, INSERT, UPDATE ON dbo.usuario TO rol_administracion;
GRANT SELECT, INSERT, UPDATE ON dbo.persona TO rol_administracion;
GRANT SELECT ON dbo.rol                     TO rol_administracion;
DENY  SELECT ON dbo.usuario(password)       TO rol_administracion;

--SUPERVISOR: PUEDE VISUALIZAR LAS VENTAS
GRANT SELECT ON dbo.venta         TO rol_supervisor;
GRANT SELECT ON dbo.detalle_venta TO rol_supervisor;
GRANT SELECT ON dbo.producto      TO rol_supervisor;

--USUARIOS DE PRUEBA PARA CADA ROL
CREATE LOGIN cajero_ejemplo		WITH PASSWORD = 'cajero123';
CREATE LOGIN inventario_ejemplo WITH PASSWORD = 'inventario123';
CREATE LOGIN admin_ejemplo		WITH PASSWORD = 'admin123';
CREATE LOGIN supervisor_ejemplo	WITH PASSWORD = 'supervisor123';

CREATE USER cajero1		FOR LOGIN cajero_ejemplo;
CREATE USER inventario1 FOR LOGIN inventario_ejemplo;
CREATE USER admin1		FOR LOGIN admin_ejemplo;
CREATE USER supervisor1 FOR LOGIN supervisor_ejemplo;

ALTER ROLE rol_cajero			ADD MEMBER cajero1;
ALTER ROLE rol_inventario		ADD MEMBER inventario1;
ALTER ROLE rol_administracion	ADD MEMBER admin1;
ALTER ROLE rol_supervisor		ADD MEMBER supervisor1;

--PRUEBAS DE IMPLEMENTACION

-- CAJERO: modificar precio directo: DEBE FALLAR
PRINT 'cajero1: UPDATE directo sobre producto (debe fallar)';
EXECUTE AS USER = 'cajero1';
UPDATE dbo.producto SET precio = precio WHERE id_producto = 1;
REVERT;
 
-- CAJERO: INSERT directo sobre venta: DEBE FALLAR
PRINT 'cajero1: INSERT directo sobre venta (debe fallar)';
EXECUTE AS USER = 'cajero1';
INSERT INTO dbo.venta (monto_total, id_medio_pago, id_persona) SELECT 0, 1, 1 WHERE 1 = 0;
REVERT;
 
-- CAJERO: registrar venta por el SP: DEBE FUNCIONAR (registra 1 leche)
PRINT 'cajero1: EXEC sp_RegistrarVentaTransaccional (debe funcionar)';
DECLARE @persona INT, @pago INT, @leche INT, @venta INT;
SELECT @persona = id_persona FROM dbo.persona WHERE email = 'martin.ferreyra@supermercado.com.ar';
SELECT TOP (1) @pago = id_medio_pago FROM dbo.medio_de_pago WHERE tipo = 'Efectivo' ORDER BY id_medio_pago;
SELECT @leche = id_producto FROM dbo.producto WHERE codigo_barra = '7790001000015';
 
SELECT nombre, stock AS stock_antes FROM dbo.producto WHERE id_producto = @leche;
 
EXECUTE AS USER = 'cajero1';
DECLARE @det dbo.DetalleVentaTransaccional;
INSERT INTO @det VALUES (@leche, 1);
EXEC dbo.sp_RegistrarVentaTransaccional @persona, @pago, @det, @venta OUTPUT;
REVERT;
 
SELECT nombre, stock AS stock_despues FROM dbo.producto WHERE id_producto = @leche;
 
-- INVENTARIO: DELETE fisico: DEBE FALLAR
PRINT 'inventario1: DELETE sobre producto (debe fallar)';
EXECUTE AS USER = 'inventario1';
DELETE FROM dbo.producto WHERE 1 = 0;
REVERT;
 
-- INVENTARIO: UPDATE de precio: DEBE FUNCIONAR
PRINT 'inventario1: UPDATE sobre producto (debe funcionar)';
EXECUTE AS USER = 'inventario1';
UPDATE dbo.producto SET precio = precio WHERE id_producto = 1;
REVERT;
 
-- ADMINISTRACION: leer contrasenas: DEBE FALLAR
PRINT 'admin1: SELECT de password (debe fallar)';
EXECUTE AS USER = 'admin1';
SELECT password FROM dbo.usuario;
REVERT;
 
-- ADMINISTRACION: leer usuarios sin la contrasena: DEBE FUNCIONAR
PRINT 'admin1: SELECT de nombre_usuario (debe funcionar)';
EXECUTE AS USER = 'admin1';
SELECT nombre_usuario, id_rol FROM dbo.usuario;
REVERT;
 
-- SUPERVISOR: ver ventas: DEBE FUNCIONAR
PRINT 'supervisor1: SELECT sobre venta (debe funcionar)';
EXECUTE AS USER = 'supervisor1';
SELECT TOP (5) * FROM dbo.venta;
REVERT;
 
-- SUPERVISOR: modificar una venta directo: DEBE FALLAR
PRINT 'supervisor1: UPDATE sobre venta (debe fallar)';
EXECUTE AS USER = 'supervisor1';
UPDATE dbo.venta SET estado = estado WHERE 1 = 0;
REVERT;

/* 
LIMPIEZA DE SEGURIDAD
    Borra los usuarios, roles y logins creados por seguridad_permisos_roles.sql,
    para poder volver a ejecutarlo desde cero. Al borrar los roles tambien se
    eliminan los permisos que tenian asignados.
*/

--En caso que la sesion quedo simulando a otro usuario, vuelve al original
REVERT;
 
-- Primero los usuarios (un rol con miembros no se puede borrar)
DROP USER IF EXISTS cajero1;
DROP USER IF EXISTS inventario1;
DROP USER IF EXISTS admin1;
DROP USER IF EXISTS supervisor1;
 
DROP ROLE IF EXISTS rol_cajero;
DROP ROLE IF EXISTS rol_inventario;
DROP ROLE IF EXISTS rol_administracion;
DROP ROLE IF EXISTS rol_supervisor;
 
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'cajero_ejemplo')     DROP LOGIN cajero_ejemplo;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'inventario_ejemplo') DROP LOGIN inventario_ejemplo;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'admin_ejemplo')      DROP LOGIN admin_ejemplo;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'supervisor_ejemplo') DROP LOGIN supervisor_ejemplo;