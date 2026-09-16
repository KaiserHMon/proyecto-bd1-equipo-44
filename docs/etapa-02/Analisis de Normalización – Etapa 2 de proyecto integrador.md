Analisis de Normalización – Etapa 2 de proyecto integrador  
Base de Datos I

**1ra Forma Normal**: Todas las tablas del diagrama cumplen con la primera forma normal. No existen datos en las tablas que no sean de carácter atómico

&nbsp;

**2da Forma Normal**: Las tablas Persona, Rol, Categoría, Producto, Usuario, Venta y Medio\_De\_Pago cumplen con la segunda normal, ya que tienen clave primaria simple.

La tabla Detalle\_venta tiene clave primaria compuesta (id\_producto y id\_venta), se debe verificar que cada atributo depende totalmente de la clave compuesta.

&nbsp;

**Subtotal** cumple con la 2FN ya que su valor depende si o si de las 2 claves compuestas. Se puede vender un producto con una misma id pero en cantidades distintas, y esto afectara el subtotal de la venta.

**Cantidad** cumple con la 2FN. Se puede vender un mismo producto pero en cantidades distintas.

**Precio\_Unitario** cumple con la 2FN ya que el valor de la venta del producto puede variar con el tiempo, y el precio que figura en la tabla original de producto puede quedar desactualizado

&nbsp;

**CAMBIOS REALIZADOS A LAS TABLAS**:

&nbsp;

* Cambio en el nombre, pasando de nombres en plural a singular.  
* En **Detalle\_Venta**: Se eliminó la clave primaria simple **id\_detalle,** ahora la clave primaria pasa a ser la combinación entre **id\_producto y id\_venta,** esto refleja mejor el funcionamiento de la tabla  
* Cambio en **Producto:** Se cambió el nombre del atributo kilogramo a peso, para que tenga sentido la existencia del atributo unidad\_medida y se puedan trabajar con unidades distintas al kilo (gramos, mililitros etc).

&nbsp;