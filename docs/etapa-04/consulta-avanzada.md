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