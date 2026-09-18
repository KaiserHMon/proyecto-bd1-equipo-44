# Proceso de Normalización – Etapa 2 del Proyecto Integrador

El proceso de normalización se realizó con el objetivo de reducir la redundancia de datos, evitar dependencias innecesarias y mejorar la integridad y consistencia de la base de datos.

## 1ra Forma Normal (1FN)

En esta etapa verificamos que: 
- Cada atributo contenga un único valor.
- No existan grupos repetitivos de atributos.
- Cada registro debe poder identificarse mediante una clave primaria.
- Los atributos deben representar valores atómicos.

En este caso el modelo ya tenia todas las tablas del diagrama cumpliendo con la primera forma normal, por lo que no fue necesaria modificarla.

## 2. Segunda Forma Normal (2FN)

En la segunda etapa se verificó el cumplimiento que establece que además de cumplir con la 1FN, todos los atributos que no forman parte de una clave deben depender de **la totalidad de la clave primaria**, y no solamente de una parte de ella.

La tabla **detalle_venta** tiene clave primaria compuesta (id_producto y id_venta), se debe verificar que cada atributo depende totalmente de la clave compuesta.

- **subtotal** cumple con la 2FN ya que su valor depende si o si de las 2 claves compuestas. Se puede vender un producto con una misma id pero en cantidades distintas, y esto afectara el subtotal de la venta.

- **cantidad** cumple con la 2FN. Se puede vender un mismo producto pero en cantidades distintas.

- **precio_unitario** cumple con la 2FN ya que el valor de la venta del producto puede variar con el tiempo, y el precio que figura en la tabla original de producto puede quedar desactualizado

Por lo tanto con esto queda verificado que el modelo tambien cumple correctamente con la segunda forma normal, el resto de claves primarias son simples por lo tanto sus atributos no pueden tener una dependencia parcial.

**3ra Forma Normal**: 

&nbsp;

**CAMBIOS REALIZADOS A LAS TABLAS**:

&nbsp;

* Cambio en el nombre, pasando de nombres en plural a singular y en snake_case.  
* En **Detalle\_Venta**: Se eliminó la clave primaria simple **id\_detalle,** ahora la clave primaria pasa a ser la combinación entre **id\_producto y id\_venta,** esto refleja mejor el funcionamiento de la tabla  
* Cambio en **Producto:** Se cambió el nombre del atributo kilogramo a peso, para que tenga sentido la existencia del atributo unidad\_medida y se puedan trabajar con unidades distintas al kilo (gramos, mililitros etc).


