# Triggers de auditoria

## ¿Que es un trigger?

Un trigger es un objeto de la base de datos que ejecuta automáticamente una lógica cuando ocurre un evento específico.

## Triggers para auditoria

Para nuestro sistema decidimos dos triggers de auditoria que nos interesaban conocer:
- Cuando se actualiza una venta, lo cual ocurre generalmente cuando cambia su estado ('En proceso', 'Completada', 'Cancelada').
- Cuando se elimina un producto.

Todo esto con el fin de conservar los datos de la entidad que se modifica/elimina y ademas para tener detalles de quien lo llevo a cabo.

## Como lo hacemos

La estructura general de un trigger de auditoría en SQL Server es la siguiente:

```sql
CREATE TRIGGER <nombre_del_trigger>
ON <tabla_que_activa_el_trigger>
AFTER <INSERT | UPDATE | DELETE>
AS
BEGIN
    INSERT INTO <tabla_de_auditoria> (
        <campos_a_completar>
    )
    SELECT
        <columnas_de_la_tabla_origen>,
        <valores_calculados>,  -- por ejemplo SYSDATETIME() o USER_NAME()
    FROM <tabla_logica>;
END;
GO
```

Cada parte cumple una función específica:

| Elemento | Descripción |
| --- | --- |
| `CREATE TRIGGER <nombre>` | Define el nombre del trigger. Conviene usar un prefijo que indique su propósito, por ejemplo `auditoria_venta_update`. |
| `ON <tabla>` | Indica la tabla cuyo cambio dispara el trigger. |
| `AFTER <acción>` | Define el momento y la acción que lo activan. `AFTER` ejecuta el trigger después de que la operación se aplicó; la acción puede ser `INSERT`, `UPDATE` o `DELETE`. |
| `INSERT INTO <tabla_de_auditoria>` | Guarda el registro histórico en la tabla de auditoría. |
| `SELECT ... FROM <tabla_logica>` | Obtiene los datos a auditar desde las tablas lógicas de SQL Server. |
| `END;` | Cierra el cuerpo del trigger. |

Sobre las tablas lógicas:

- `inserted` contiene las versiones nuevas de las filas afectadas (útil en `INSERT` y `UPDATE`).
- `deleted` contiene las versiones anteriores de las filas afectadas (útil en `UPDATE` y `DELETE`).

Por eso, para auditar una actualización usamos `deleted` (el estado previo) y para auditar una eliminación también `deleted`, ya que la fila original deja de existir en la tabla.

Ejemplo aplicado a nuestro caso, auditando la actualización de una venta:

```sql
CREATE TRIGGER dbo.auditoria_venta_update
ON dbo.venta
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.auditoria_venta (
        id_venta,
        monto_total,
        estado,
        fecha_auditoria,
        usuario_bd
    )
    SELECT
        d.id_venta,
        d.monto_total,
        d.estado,
        SYSDATETIME(),
        USER_NAME()
    FROM deleted AS d;
END;
GO
```
