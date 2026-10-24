# Triggers de auditoria

## ¿Que es un trigger?

Un trigger es un objeto de la base de datos que ejecuta automáticamente una lógica cuando ocurre un evento específico.

## Triggers para auditoria

Para nuestro sistema decidimos dos triggers de auditoria que nos interesaban conocer:
- Cuando se actualiza una venta, lo cual ocurre generalmente cuando cambia su estado ('En proceso', 'Completada', 'Cancelada').
- Cuando se elimina un producto.

Todo esto con el fin de conservar los datos de la entidad que se modifica/elimina y ademas para tener detalles de quien lo llevo a cabo.

## Como lo hacemos

'Creacion y definicion del trigger'
CREATE TRIGGER
ON 'tabla que activa el trigger'
'El momento en el que se activa BEFORE/AFTER' 'la accion que lo activa INSERT/UPDATE/DELETE'
AS
BEGIN
    INSERT INTO 'la tabla de auditoria que usamos para guardar los datos'
    (
        'los campos que vamos a completar'
    )
    SELECT
        'los datos de la tabla que ejecuta el trigger que queremos guarda y los personalizados que definimos nosotros como SYSDATETIME()'
    FROM 'estas son tablas logicas que proporciona SQL Server puede ser: inserted (contiene las nuevas versiones de las filas afectadas) o deleted (contiene las versiones anteriores de las filas afectadas)'
END;
'Fin del trigger'
