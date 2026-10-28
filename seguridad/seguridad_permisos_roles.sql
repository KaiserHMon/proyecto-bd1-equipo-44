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