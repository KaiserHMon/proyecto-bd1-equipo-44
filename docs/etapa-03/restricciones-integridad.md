# Restricciones

## 1. Claves Foráneas (`FOREIGN KEY`)
* **Qué hace:** Conecta las tablas dependientes (`usuario`, `producto`, `tarjeta`, `venta`, `detalle_venta`) con sus respectivas tablas maestras (`rol`, `persona`, `categoria`, `unidad_medida`, `banco`, `medio_de_pago`).
* **Por qué:** Garantiza la integridad referencial, evitando que se inserten registros huérfanos (por ejemplo, una venta asociada a un cliente o medio de pago que no existe).

## 2. Restricciones de Unicidad (`UNIQUE`)
* **Qué hace:** Asegura que campos como `numero_tarjeta` en la tabla `tarjeta` no se repitan.
* **Por qué:** Evita duplicidad de datos sensibles y asegura que cada elemento único se identifique de forma unívoca.

## 3. Restricciones de Validación (`CHECK`)
* **Fechas (`eliminado_en >= creado_en`):**
  * **Por qué:** Para los casos de borrado logico esta restriccion impide que un registro tenga una fecha de eliminación anterior a su fecha de creación, permitiendo que el campo sea nulo mientras el registro esté activo (`IS NULL`).
* **Correos electrónicos (`email LIKE '%@%._%'`):**
  * **Por qué:** Realiza una validación básica para asegurar que los correos ingresados en la tabla `persona` tengan una estructura mínima válida.
* **Precios, stocks y cantidades (`precio > 0`, `stock >= 0`, `cantidad > 0`, etc):**
  * **Por qué:** Evita errores lógicos de negocio, bloqueando el ingreso de precios negativos, stocks en negativo o cantidades de venta menores o iguales a cero.
* **Estados y Tipos (`IN (...)`):**
  * **Por qué:** Limita los valores permitidos en columnas (como los estados de la venta: `'En proceso', 'Completada', 'Cancelada', 'Reembolsada'` o los tipos de tarjeta), asegurando que no se guarden cadenas de texto erróneas o tipeadas por accidente.

## 4. Restriccion de Valor Predeterminado (`DEFAULT`)
* **Qué hace:** Asigna de manera automática un valor por defecto (como `CURRENT_TIMESTAMP` para las fechas de creación o `'En proceso'` para estados iniciales) a una columna cuando el comando de inserción `(INSERT)` omite ese campo.
* **Por qué:** Evita que tengas que enviar manualmente valores predeterminados desde tu aplicación en cada inserción, garantizando la consistencia de los datos y simplificando las consultas de inserción.