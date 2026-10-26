# Consultas Avanzadas

## Analisis de Productos Mas Vendidos por Categoria

Esta consulta nos ayuda a responder la pregunta "¿Cuales son los productos activos de nuestro supermercado, agrupados por su categoria, que se vendieron 25 unidades o mas en ventas completadas, y cuanto dinero total han ingresado?"

---

### ¿Cuales son los beneficios de saber esto?

* Al cruzar el stock actual con las unidades vendidas, el personal de inventario puede detectar rapidamente si un producto de mucha venta se esta quedando sin stock fisico.
* Permite saber que categorias de productos estan traccionando realmente el negocio y cuales estan ocupando espacio valioso en el supermercado sin generar un volumen de venta significativo.
* Saber con precision que marcas o productos especificos generan mayor ingreso total le da al administrador herramientas de peso para negociar mejores precios de compra con los proveedores.
* Ayuda a decidir donde enfocar las ofertas o que productos conviene ubicar en zonas estrategicas de la sucursal o por el contrario, que productos bajo el umbral de las 25 unidades necesitan una liquidación de stock.

---

### ¿Como lo hace la consulta?

* **SELECT:** Definimos que columnas queremos ver en el resultado final (categoria, nombre del producto, stock actual, ingreso total y cuantas unidades se vendieron).
* **INNER JOIN:** Conectamos las tablas relacionadas (ventas, categoria, producto y detalle_venta).
* **WHERE:** Filtramos solo ventas que fueron completadas y que sean productos que no esten eliminados.
* **GROUP BY:** Definimos como se van a ir agrupando los registros al final de la consulta.
* **HAVING:** Filtramos los resultados que tengan un numero de ventas mayor o igual a 1 unidades como parametro minimo definido por nosotros (es para que funcione con los datos de prueba pero en realidad deberia ser de un minimo/igual mayor).
* **ORDER BY:** Ordenamos de que manera se van a mostrar los datos, en este caso primero por el que tenga el ingreso total maximo.

## Analisis de Ingresos por Banco y Tarjeta

Esta consulta nos ayuda a responder la pregunta "¿Cuales son los bancos y tarjetas activas en nuestro supermercado que han recaudado $5.000 o mas en ventas completadas, cuantas operaciones realizaron y cuanto dinero total ingresaron?"

---

### ¿Cuales son los beneficios de saber esto?

* Permite identificar rapidamente que entidades bancarias y marcas de tarjetas generan el mayor ingreso de dinero en el supermercado para negociar promociones o descuentos con esos bancos.
* Ayuda a conocer la preferencia de pago de los clientes (si utilizan mas tarjeta de Debito, Credito o Prepaga) para prever los tiempos de acreditacion del dinero en la cuenta del comercio.
* Asegura que el analisis se realice unicamente sobre cobros reales y efectivos, descartando ventas canceladas, en proceso o medios de pago que hayan sido dados de baja.
* Permite filtrar y descartar del reporte aquellas tarjetas con un volumen de recaudacion marginal (menor al monto minimo establecido), enfocando la atencion en los medios de pago mas rentables.

---

### ¿Como lo hace la consulta?

* **SELECT:** Definimos que columnas queremos ver en el resultado final (nombre del banco, tipo de tarjeta, marca, cantidad de ventas realizadas y el ingreso total recaudado).
* **INNER JOIN:** Conectamos las tablas relacionadas (`tarjeta`, `medio_de_pago`, `banco` y `venta`) mediante sus claves primarias y foraneas para cruzar los datos de la tarjeta con su entidad bancaria y sus ventas asociadas.
* **WHERE:** Filtramos solo las ventas que fueron completadas y que correspondan a medios de pago que no esten eliminados.
* **GROUP BY:** Definimos como se van a ir agrupando los registros al final de la consulta (por banco, tipo de tarjeta y marca).
* **HAVING:** Filtramos los grupos resultantes que tengan un ingreso total acumulado mayor o igual a $5.000 como parametro minimo definido por nosotros para los datos de prueba.
* **ORDER BY:** Ordenamos de que manera se van a mostrar los datos, en este caso primero por el que tenga el ingreso total maximo.