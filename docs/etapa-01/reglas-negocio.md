# Reglas de Negocio (RN)

| Código | Regla |
| :--- | :--- |
| **RN.01** | Todo empleado debe autenticarse con credenciales únicas (usuario y contraseña) antes de acceder a cualquier funcionalidad del sistema. |
| **RN.02** | Cada usuario tiene asignado un único rol que determina sus permisos. Los roles válidos son: Cajero, Personal de Inventario, Administración y Supervisor de Caja. |
| **RN.03** | El cajero no tiene permiso para modificar manualmente el stock ni los precios de los productos; esas operaciones están restringidas exclusivamente al personal de inventario. |
| **RN.04** | Al registrar una venta, el sistema almacena el precio unitario vigente de cada producto en el detalle de la transacción. Un cambio posterior de precios no altera los registros de ventas ya realizadas. |
| **RN.05** | El stock de un producto se descuenta automáticamente al concretar una venta. No existe descuento manual desde el rol de caja. |
| **RN.06** | Las eliminaciones de usuarios, productos y categorías son bajas lógicas para mantener la integridad de los datos históricos. Ningún registro con referencias activas se elimina físicamente. |
| **RN.07** | Toda venta debe registrar obligatoriamente el medio de pago utilizado. |
| **RN.08** | Solo el Supervisor de Caja puede eliminar un producto registrado erróneamente en la lista de compras de un cajero. El cajero no puede realizar esta corrección por sí mismo. |
| **RN.09** | Los productos se identifican en el punto de venta mediante su código de barras o por búsqueda por nombre. |
| **RN.10** | Cada persona registrada debe tener a lo sumo una cuenta de usuario y cada cuenta debe pertenecer a una única persona ($1:1$ condicional). |
| **RN.11** | Un rol puede ser asignado a muchos usuarios, mientras que cada usuario tiene exactamente un rol ($1:N$). |
| **RN.12** | Una categoría tiene muchos productos y cada producto pertenece a una sola categoría ($1:N$). |
| **RN.13** | Un cajero registra muchas ventas a lo largo de su jornada y cada venta corresponde a un único usuario ($1:N$). |
| **RN.14** | Cada venta se salda con un único medio de pago y un mismo medio de pago puede aparecer en muchas ventas ($1:N$). |
| **RN.15** | Una venta contiene uno o varios productos y un producto puede aparecer en varias ventas ($N:M$). |