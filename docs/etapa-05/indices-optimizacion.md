# Indices y optimizacion de consultas

## ¿Que es un indice?

Un índice es una estructura aparte que el motor mantiene ordenada por una o más columnas, con punteros a las filas de la tabla. Sirve para no tener que leer la tabla entera cuando buscamos un valor o un rango chico. Es la misma idea que el índice de un libro: en lugar de pasar hoja por hoja, vas directo a las páginas que te interesan.


## Tipos que nos interesan

| Tipo | Como trabaja | Cuantos admite la tabla |
| --- | --- | --- |
| Agrupado (clustered) | Ordena físicamente la tabla por la clave. La hoja del índice es la tabla misma. | Uno solo |
| No agrupado (nonclustered) | Estructura separada, con la clave y un puntero a la fila. | Hasta 999 |

El no agrupado tiene un costo escondido: si la consulta pide columnas que no están en el índice, por cada fila encontrada el motor tiene que ir a la tabla a buscarlas. Agregando esas columnas con `INCLUDE`, el índice pasa a cubrir la consulta y ese ida y vuelta desaparece.

## El caso que medimos

No usamos la tabla `venta` del modelo porque su PK ya ocupa el índice agrupado y desarmarla afectaría al resto del proyecto. Armamos una tabla aparte, `dbo.venta_historica`, con las mismas columnas de una venta pero sin restricciones, y la cargamos con 1.000.000 de filas. Las fechas van del 2023-10-01 al 2026-09-30, o sea que hay ventas repartidas en 3 años.

Sobre esa tabla siempre corremos la misma consulta: el listado de ventas de la primera semana de marzo de 2026.

```sql
SELECT
    fecha_venta,
    monto_total,
    estado,
    id_medio_pago,
    id_persona
FROM dbo.venta_historica
WHERE fecha_venta >= '2026-03-02'
  AND fecha_venta <  '2026-03-09'
ORDER BY fecha_venta;
```

## Como medimos

Para cada prueba corrimos el script y anotamos tres cosas: el operador principal del plan, las lecturas lógicas que informa `SET STATISTICS IO` y el tiempo de respuesta de `SET STATISTICS TIME`.

Un detalle que nos pareció importante: el tiempo se mueve bastante entre corridas de la misma prueba (la consulta sin índice nos dio 101 ms en una corrida y 185 ms en otra, con la misma máquina). Las lecturas lógicas, en cambio, dan siempre el mismo número, así que son el dato que usamos para comparar. Los milisegundos los tomamos como referencia.

## Scripts

| Script | Que hace |
| --- | --- |
| [01_carga_masiva.sql](../../sql/tecnico/indices/01_carga_masiva.sql) | Crea `dbo.venta_historica` sin índices y la carga con 1.000.000 de filas. |
| [02_consulta_sin_indice.sql](../../sql/tecnico/indices/02_consulta_sin_indice.sql) | Prueba 1: la consulta con la tabla sin indices. |
| [03_indice_agrupado.sql](../../sql/tecnico/indices/03_indice_agrupado.sql) | Prueba 2: crea el índice agrupado sobre `fecha_venta` y repite la consulta. |
| [04_borrar_indice.sql](../../sql/tecnico/indices/04_borrar_indice.sql) | Prueba 3: borra el índice agrupado. |
| [05_indice_no_agrupado.sql](../../sql/tecnico/indices/05_indice_no_agrupado.sql) | Prueba 4: índice no agrupado sobre `fecha_venta`, sin columnas incluidas. |
| [06_indice_cobertura.sql](../../sql/tecnico/indices/06_indice_cobertura.sql) | Prueba 5: índice no agrupado con las columnas del SELECT en `INCLUDE`. |
| [07_limpieza.sql](../../sql/tecnico/indices/07_limpieza.sql) | Borra la tabla de prueba y la tabla auxiliar de números. |

---

## Prueba 1: busqueda por periodo sin indice

La tabla arranca como heap, sin ningún índice sobre `fecha_venta`. El motor no tiene otro camino que leer las 1.000.000 de filas y quedarse con las del período.

```sql
SELECT
    fecha_venta,
    monto_total,
    estado,
    id_medio_pago,
    id_persona
FROM dbo.venta_historica
WHERE fecha_venta >= '2026-03-02'
  AND fecha_venta <  '2026-03-09'
ORDER BY fecha_venta;
```

El plan tiene dos operadores: un **Table Scan** que lee la tabla entera y, por encima, un **Sort** que ordena las 5.383 filas que sobreviven al filtro. Fueron **7.410 lecturas lógicas** y **185 ms**, con 78 ms de CPU. El costo estimado del plan es de 7,66.

Una curiosidad: el propio optimizador dejó anotada la sugerencia de índice que faltaba, con un impacto estimado del 73%.

## Prueba 2: indice agrupado sobre la fecha

```sql
CREATE CLUSTERED INDEX ix_venta_historica_fecha
ON dbo.venta_historica (fecha_venta);
```

Al crear el agrupado, SQL Server reordena las filas por `fecha_venta` y las páginas quedan encadenadas en ese orden. La consulta pasa a resolver el rango con un **Clustered Index Seek**, que lee las páginas del período y nada más.

Bajó a **45 lecturas lógicas** y **37 ms**, con menos de 1 ms de CPU. El costo estimado pasó de 7,66 a 0,0396. Además el `Sort` desapareció: el seek devuelve las filas ordenadas por `fecha_venta`, así que el motor ya no tiene que ordenar nada.

Como la hoja del agrupado es la tabla entera, este índice ya trae todas las columnas.

## Prueba 3: borrar el indice

```sql
DROP INDEX ix_venta_historica_fecha ON dbo.venta_historica;
```

Borramos el  indice para probar el agrupado.

## Prueba 4: indice no agrupado sin columnas incluidas

```sql
CREATE NONCLUSTERED INDEX ix_venta_historica_fecha_no_agrupado
ON dbo.venta_historica (fecha_venta);
```

El índice encuentra el período sin leer toda la tabla, pero la clave solo tiene `fecha_venta`: para cada una de las 5.383 filas tendría que ir a buscar `monto_total`, `estado`, `id_medio_pago` e `id_persona`.

El optimizador hizo la cuenta y **decidió no usarlo**: el plan volvió a ser el mismo `Table Scan` + `Sort` de la prueba 1, con **7.693 lecturas** (el heap quedó más grande después de borrar el agrupado), **147 ms de tiempo total** y **94 ms de CPU**. Prefirió leer 7.693 páginas seguidas antes que hacer miles de búsquedas sueltas. El índice existía, pero para esta consulta no servía de nada.

Para confirmar que el lookup era el problema, repetimos la consulta forzando el índice con un hint:

```sql
SELECT fecha_venta, monto_total, estado, id_medio_pago, id_persona
FROM dbo.venta_historica WITH (INDEX(ix_venta_historica_fecha_no_agrupado))
WHERE fecha_venta >= '2026-03-02'
  AND fecha_venta <  '2026-03-09'
ORDER BY fecha_venta;
```

Ahí sí apareció el **Index Seek**. Las lecturas subieron a 5.401, con **58 ms de tiempo total** y **menos de 1 ms de CPU**. Es más rápido que el scan en esta máquina, pero se nota que el motor tuvo que hacer un trabajo extra que con las columnas incluidas no hace falta.

## Prueba 5: indice que cubre la consulta

La consigna pide un índice agrupado sobre la fecha que además incluya las columnas seleccionadas.
Eso no se puede: SQL Server no admite `INCLUDE` sobre un índice agrupado (error 10601), porque la hoja del agrupado ya trae todas las columnas de la tabla.
Lo que hicimos fue crear un índice no agrupado sobre la fecha con las columnas del `SELECT` en `INCLUDE`. Con eso el índice tiene todo lo que la consulta necesita y el lookup desaparece:

```sql
CREATE NONCLUSTERED INDEX ix_venta_historica_fecha_cobertura
ON dbo.venta_historica (fecha_venta)
INCLUDE (monto_total, estado, id_medio_pago, id_persona);
```

El plan quedó en un único **Index Seek**, con **40 lecturas lógicas**, **23 ms de tiempo total** y **menos de 1 ms de CPU**. Es el mejor resultado de los cuatro, incluso un poco mejor que el agrupado.

El precio es el espacio. Este índice ocupa casi lo mismo que la tabla porque `fecha_venta` es prácticamente única y además arrastra cuatro columnas, y hay que mantenerlo en cada INSERT y UPDATE de la tabla.

---

## Resultados

| Prueba | Indice | Operador principal | Lecturas logicas | Tiempo | CPU |
| --- | --- | --- | --- | --- | --- |
| 1 | Ninguno (heap) | Table Scan + Sort | 7.410 | 185 ms | 78 ms |
| 2 | Agrupado en `fecha_venta` | Clustered Index Seek | 45 | 37 ms | < 1 ms |
| 3 | Se borra el agrupado | — | — | — | — |
| 4 | No agrupado en `fecha_venta` | Table Scan + Sort (el indice se ignora) | 7.693 | 147 ms | 94 ms |
| 5 | No agrupado con `INCLUDE` | Index Seek | 40 | 23 ms | < 1 ms |
| Extra | No agrupado forzado con hint | Index Seek + RID Lookup | 5.401 | 58 ms | < 1 ms |

## Conclusiones

El índice agrupado sobre la fecha es el que más cambia la historia en este caso: 7.410 lecturas contra 45 y encima desaparece el `Sort` porque el recorrido ya sale ordenado.

Pero el resultado más interesante fue la prueba 4. Tener un índice sobre la columna del filtro no alcanza: si la consulta necesita otras columnas, cada fila encontrada cuesta una búsqueda más, y llega un punto en el que el optimizador prefiere ignorar el índice y leer la tabla entera.

`INCLUDE` es la respuesta a eso, y es la única forma de "incluir columnas". Con el índice de cobertura el plan quedó en un solo Seek, sin lookups y sin Sort, con 40 lecturas.
