# Procedimientos y Funciones Almacenadas en SQL Server

## 1. Procedimientos Almacenados (Stored Procedures)

### 1.1 Definición y Objetivo
* **Definición:** Un procedimiento almacenado es un conjunto de instrucciones SQL que se guarda compilado dentro del motor de base de datos. Se ejecuta mediante comandos como `EXEC` y puede recibir parámetros, devolver datos, manejar transacciones y modificar registros (`INSERT`, `UPDATE`, `DELETE`).
* **Objetivo:** Agrupar tareas o procesos completos del sistema en el servidor, evitando repetir código en la aplicación y asegurando que las reglas de negocio se cumplan siempre de la misma forma.

### 1.2 Ventajas
* **Mejor rendimiento:** SQL Server analiza y compila el procedimiento la primera vez que se ejecuta; después reutiliza ese plan en memoria, ahorrando tiempo de procesamiento.
* **Menos tráfico de red:** La aplicación solo envía el nombre del procedimiento y sus parámetros (`EXEC sp_InsertarProducto ...`), en lugar de enviar sentencias SQL largas en cada operación.
* **Mayor seguridad:** Permite dar permisos al usuario para ejecutar el procedimiento sin darle acceso directo a modificar las tablas del sistema, reduciendo riesgos de seguridad y errores humanos.
* **Control de transacciones:** Facilita abrir y cerrar transacciones (`COMMIT` o `ROLLBACK`) para que las operaciones se completen por entero o no se guarde nada si ocurre un fallo.

### 1.3 Aplicaciones habituales
* Carga de una venta junto con su detalle de productos de forma segura.
* Modificación de registros actualizando automáticamente fechas de auditoría (`actualizado_en`).
* Procesos de borrado lógico marcando una fecha de baja (`eliminado_en`) sin destruir la fila física.

---

## 2. Funciones Almacenadas (User-Defined Functions)

### 2.1 Definición y Objetivo
* **Definición:** Una función es una rutina guardada en la base de datos que recibe datos de entrada, realiza un cálculo o consulta y **siempre devuelve un resultado**. Puede devolver un solo valor (función escalar) o un conjunto de filas (función de tabla).
* **Objetivo:** Encapsular fórmulas, conversiones o filtros repetitivos para utilizarlos directamente dentro de consultas `SELECT`, `WHERE` o `JOIN`.

### 2.2 Ventajas
* **Reutilización:** Una misma fórmula (por ejemplo, calcular el IVA o recargos) se define en un único lugar y se puede llamar desde cualquier reporte o consulta.
* **Mantenimiento simple:** Si la fórmula cambia, solo se modifica la función y el cambio impacta de inmediato en todas las consultas del sistema.
* **Uso directo en consultas:** Se comportan como funciones propias del motor (igual que `UPPER()` o `ROUND()`), facilitando la lectura del código SQL.

### 2.3 Aplicaciones habituales
* Cálculo del precio final de un producto sumándole el IVA.
* Obtención del total histórico gastado por un cliente.
* Listado filtrado de productos activos pertenecientes a una categoría.

---
