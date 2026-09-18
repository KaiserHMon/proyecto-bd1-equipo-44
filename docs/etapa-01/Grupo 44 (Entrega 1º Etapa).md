## Grupo Nº44:

## Integrantes:

- Harvey Benjamin

- Rojas Marcos Agustin

- Sanchez Cueba Tobias Agustin

- Santoro Sandoval Lionel Adolfo

- Hardoy Juan Segundo

## Título del Tema

Sistema de Punto de Venta para Supermercado de Sucursal Única.

## Descripción Completa del Caso

El sistema es una aplicación de escritorio diseñada para una marca de supermercado que opera en una única sucursal. Su propósito es informatizar las operaciones diarias del punto de venta: registro de compras, gestión de inventario y administración de usuarios.

El sistema contempla cuatro roles de usuario con permisos diferenciados:

- Cajero: Registra las compras escaneando o ingresando manualmente el código de barras de cada producto. Genera el ticket de compra y el stock se actualiza automáticamente al finalizar la transacción, sin que pueda modificarlo manualmente. (Un cajero puede registrar múltiples compras, pero cada compra está asociada a un único cajero y se abona con un solo medio de pago. Una venta está formada por varios productos y un mismo producto puede aparecer en varias ventas).

- Personal de Inventario: Se encarga de mantener el catálogo, lo que incluye crear, eliminar o modificar productos y categorías. (Una categoría puede agrupar muchos productos, pero cada producto pertenece a una sola categoría).

- Administración: Gestiona las cuentas de usuario del sistema (altas, bajas y modificación de roles), asignando a cada usuario un solo rol y vinculándolo a una única persona.

- Supervisor de Caja: Interviene para corregir errores puntuales en las transacciones en curso; por ejemplo, puede eliminar un producto registrado erróneamente en la lista del cajero.

Cada venta registra el precio unitario vigente en el momento de la transacción, garantizando un historial fiel que no se altera ante cambios de precio posteriores. Asimismo, toda venta queda asociada al medio de pago utilizado y al cajero que realizó la operación. Las eliminaciones de usuarios, productos y categorías se realizan mediante baja lógica para preservar la integridad referencial de los datos históricos.


## Alcance del Sistema

Autenticación de empleados por credenciales (login), gestión de usuarios y roles por parte de la administración, registro de ventas en caja con búsqueda por código de barras o nombre, generación de tickets, descuento automático de stock al concretar ventas, gestión de inventario (stock, precios, productos y categorías), registro de clientes, registro del medio de pago utilizado en cada venta y corrección de errores en compras en proceso por parte del supervisor de caja.

## Reglas de Negocio

RN.01 — Todo empleado debe autenticarse con credenciales únicas (usuario y contraseña) antes de acceder a cualquier funcionalidad del sistema.

RN.02 — Cada usuario tiene asignado un único rol que determina sus permisos. Los roles válidos son: Cajero, Personal de Inventario, Administración y Supervisor de Caja.

RN.03 — El cajero no tiene permiso para modificar manualmente el stock ni los precios de los productos; esas operaciones están restringidas exclusivamente al personal de inventario.

RN.04 — Al registrar una venta, el sistema almacena el precio unitario vigente de cada producto en el detalle de la transacción. Un cambio posterior de precios no altera los registros de ventas ya realizadas.

RN.05 — El stock de un producto se descuenta automáticamente al concretar una venta. No existe descuento manual desde el rol de caja.

RN.06 — Las eliminaciones de usuarios, productos y categorías son bajas lógicas para mantener la integridad de los datos históricos. Ningún registro con referencias activas se elimina físicamente.

RN.07 — Toda venta debe registrar obligatoriamente el medio de pago utilizado.

RN.08 — Solo el Supervisor de Caja puede eliminar un producto registrado erróneamente en la lista de compras de un cajero. El cajero no puede realizar esta corrección por sí mismo.

RN.09 — Los productos se identifican en el punto de venta mediante su código de barras o por búsqueda por nombre.

RN.10 — Cada persona registrada debe tener a lo sumo una cuenta de usuario y cada cuenta debe pertenecer a una única persona.

RN.11 — Un rol puede ser asignado a muchos usuarios, mientras que cada usuario tiene exactamente un rol.


RN.12 — Una categoría tiene muchos productos y cada producto pertenece a una sola

categoría.

RN.13 — Un cajero registra muchas ventas a lo largo de su jornada y cada venta

corresponde a un único usuario.

RN.14 — Cada venta se salda con un único medio de pago y un mismo medio de pago

puede aparecer en muchas ventas.

RN.15 — Una venta contiene uno o varios productos y un producto puede aparecer en varias ventas.
