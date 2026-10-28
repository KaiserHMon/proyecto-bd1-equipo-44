# Manejo de transacciones

## 1. Definición y objetivo

Una **transacción** es un conjunto de operaciones SQL que el motor trata como una única unidad lógica de trabajo. La transacción se confirma con `COMMIT` cuando todas las operaciones terminan correctamente. Si alguna falla, se utiliza `ROLLBACK` para deshacer los cambios realizados dentro de ella.

El objetivo en el sistema de ventas es impedir que la base quede en un estado inconsistente. Una compra no debe registrarse parcialmente: el encabezado de la venta, sus productos y la actualización del inventario tienen que confirmarse juntos.

### Propiedades ACID

- **Atomicidad:** se realizan todos los cambios o ninguno. Si falla el descuento de stock, se revierten la venta y sus detalles.
- **Consistencia:** las restricciones y las validaciones mantienen reglas como cantidades positivas, claves foráneas válidas y stock no negativo.
- **Aislamiento:** durante la operación se mantienen bloqueos sobre los productos consultados para reducir el riesgo de que dos cajas utilicen simultáneamente el mismo stock disponible.
- **Durabilidad:** después de confirmar con `COMMIT`, los cambios quedan guardados en la base de datos.

## 2. Ventajas y aplicaciones

En el supermercado, las transacciones ofrecen estas ventajas:

1. **Evitan ventas incompletas.** No queda una fila en `venta` sin sus correspondientes filas en `detalle_venta`.
2. **Protegen el inventario.** Una venta no puede confirmarse si no se logra descontar la cantidad de todos los productos solicitados.
3. **Mantienen los importes coherentes.** El total se calcula a partir de los precios y cantidades incluidas en la operación.
4. **Conservan el precio histórico.** Cada renglón guarda el valor vigente en `detalle_venta.precio_unitario`; un cambio posterior en `producto.precio` no modifica las ventas previas.
5. **Ayudan ante errores o concurrencia.** Los mecanismos de bloqueo y el control transaccional reducen el riesgo de descontar dos veces una disponibilidad insuficiente.
6. **Facilitan la recuperación.** Si aparece un error durante la venta, SQL Server puede revertir el conjunto completo de cambios.

## 3. Implementación en SQL Server Express

SQL Server Express permite implementar transacciones con instrucciones T-SQL. En el script se utilizaron:

| Instrucción o recurso | Función dentro del proyecto |
|---|---|
| `BEGIN TRANSACTION` | Inicia la unidad de trabajo. |
| `COMMIT TRANSACTION` | Confirma la venta, el detalle y el descuento de stock cuando todo termina correctamente. |
| `ROLLBACK TRANSACTION` | Revierte todas las operaciones de la transacción cuando se detecta un error. |
| `TRY...CATCH` | Captura errores y dirige la ejecución al bloque que revierte la operación. |
| `SET XACT_ABORT ON` | Hace que determinados errores de ejecución cancelen la transacción actual; el bloque `CATCH` realiza el rollback explícito. |
| `UPDLOCK, HOLDLOCK` | Mantiene bloqueos sobre los productos consultados hasta que termine la transacción, ayudando a evitar conflictos de stock entre operaciones concurrentes. |
| `THROW` | Genera errores controlados ante datos inválidos o stock insuficiente. |

## 4. Caso concreto aplicado al sistema de ventas del equipo

En el modelo compartido, las tablas involucradas son:

- `venta`: almacena el encabezado, el total, el estado, la fecha, el medio de pago y la persona asociada a la venta.
- `detalle_venta`: registra cada producto, la cantidad, el precio unitario histórico y el subtotal.
- `producto`: contiene el precio vigente y el stock disponible.
- `persona` y `medio_de_pago`: permiten comprobar las referencias obligatorias de la venta.

### Flujo de una venta correcta

1. Se valida que haya productos y que las cantidades sean mayores que cero.
2. Se verifica que la persona y el medio de pago estén activos.
3. Se comprueba la existencia de cada producto y se mantienen bloqueos durante la transacción.
4. Se calcula el total usando `producto.precio`.
5. Se inserta el encabezado en `venta`.
6. Se insertan las líneas en `detalle_venta`, guardando `precio_unitario` y `subtotal`.
7. Se descuenta el stock.
8. Si se actualizó el stock de todos los productos solicitados, se ejecuta `COMMIT`.

### Flujo con stock insuficiente

La segunda demostración solicita una cantidad de arroz superior a la disponible y agrega otro producto que sí tiene stock. El procedimiento inserta temporalmente el encabezado y los detalles dentro de la transacción e intenta descontar el inventario. Como no puede actualizar todos los productos pedidos, genera un error. El bloque `CATCH` ejecuta `ROLLBACK`, por lo que se deshacen también los cambios que sí se habían podido realizar.

## 5. Script de demostración y resultados esperados

El archivo `transacciones_supermercado.sql` contiene las dos pruebas. Los siguientes valores se calculan a partir de los datos cargados en la base.

### Prueba 1: compra correcta

Datos de ejemplo:

| Producto | Precio unitario del ejemplo | Cantidad | Subtotal |
|---|---:|---:|---:|
| Leche entera sachet 1 L | $1.250,00 | 2 | $2.500,00 |
| Arroz largo fino 1 kg | $1.890,00 | 1 | $1.890,00 |
| **Total esperado** |  |  | **$4.390,00** |

Con los stocks iniciales, la leche pasa de 120 a 118 unidades y el arroz pasa de 150 a 149 unidades. La salida de la consulta debe mostrar una venta `Completada`, su detalle y el stock actualizado.

### Prueba 2: compra con stock insuficiente

La demostración intenta vender una unidad de leche y 9.999 unidades de arroz. La cantidad de arroz excede ampliamente el stock de prueba.

Resultado esperado:

| Verificación | Resultado esperado |
|---|---|
| Ventas agregadas por la prueba fallida | `0` |
| Detalles agregados por la prueba fallida | `0` |
| Stock de leche después del intento | Igual al stock previo al intento |
| Stock de arroz después del intento | Igual al stock previo al intento |
| Mensaje de verificación | `CORRECTO: ROLLBACK completo, sin cambios parciales.` |

Los resultados numéricos son esperados, no una medición ejecutada en este entorno. La última consulta del script hace la comparación contra los conteos y stocks guardados justo antes de la operación fallida; de esa manera se puede comprobar el resultado real al correrlo.
