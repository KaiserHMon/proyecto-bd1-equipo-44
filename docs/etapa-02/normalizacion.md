# Proceso de Normalización – Etapa 2 del Proyecto Integrador

El proceso de normalización se realizó con el objetivo de reducir la redundancia de datos, evitar dependencias innecesarias y mejorar la integridad y consistencia de la base de datos.

## 1ra Forma Normal (1FN)

En esta etapa verificamos que: 
- Cada atributo contenga un único valor.
- No existan grupos repetitivos de atributos.
- Cada registro debe poder identificarse mediante una clave primaria.
- Los atributos deben representar valores atómicos.

En este caso el modelo ya tenia todas las tablas del diagrama cumpliendo con la primera forma normal, por lo que no fue necesaria modificarla.

---

## 2. Segunda Forma Normal (2FN)

En la segunda etapa se verificó el cumplimiento que establece que además de cumplir con la 1FN, todos los atributos que no forman parte de una clave deben depender de **la totalidad de la clave primaria**, y no solamente de una parte de ella.

La tabla **detalle_venta** tiene clave primaria compuesta (id_producto y id_venta), se debe verificar que cada atributo depende totalmente de la clave compuesta.

- **subtotal** cumple con la 2FN ya que su valor depende si o si de las 2 claves compuestas. Se puede vender un producto con una misma id pero en cantidades distintas, y esto afectara el subtotal de la venta.

- **cantidad** cumple con la 2FN. Se puede vender un mismo producto pero en cantidades distintas.

- **precio_unitario** cumple con la 2FN ya que el valor de la venta del producto puede variar con el tiempo, y el precio que figura en la tabla original de producto puede quedar desactualizado

Por lo tanto con esto queda verificado que el modelo tambien cumple correctamente con la segunda forma normal, el resto de claves primarias son simples por lo tanto sus atributos no pueden tener una dependencia parcial.

---

# 3. Tercera Forma Normal (3FN)

La mayor parte de los cambios realizados en el diagrama corresponden a la Tercera Forma Normal.

La 3FN busca eliminar las dependencias transitivas, es decir, situaciones en las que un atributo depende de otro atributo que no es la clave primaria, en lugar de depender directamente de la clave de su propia entidad.

### 3.1. Normalización de los medios de pago

En el modelo inicial, `tarjeta` tenia un atributo banco el cual se podia repetir entre múltiples tarjetas.

```text
tarjeta
----------------
id_medio_pago
tipo_tarjeta
marca_tarjeta
numero_tarjeta
fecha_vencimiento
creado_en
banco
```

Para evitar esta redundancia, se creó la entidad `banco`:

```text
tarjeta
----------------
id_medio_pago
tipo_tarjeta
marca_tarjeta
numero_tarjeta
fecha_vencimiento
creado_en
id_banco
```

```text
banco
----------------
id_banco
nombre
```

De esta manera, los datos propios del banco se almacenan en `banco`.

Esto nos evita:
- Repetir información del banco para cada tarjeta y permite que un mismo banco pueda estar asociado a múltiples tarjetas.

---

### 3.2. Normalización de la unidad de medida

En el modelo inicial, `producto` almacenaba directamente la unidad de medida como un atributo:

```text
producto
----------------
...
unidad_medida
kilogramo
...
```

En el modelo normalizado se creó una entidad específica:

```text
unidad_medida
----------------
id_unidad_medida
nombre
abreviatura
```

Y `producto` pasó a almacenar solamente una referencia:

```text
producto
----------------
...
id_unidad_medida (FK)
...
```

De esta forma, la información de la unidad de medida se mantiene en un único lugar.

Por ejemplo, en lugar de almacenar repetidamente diferentes valores de unidad de medida en los productos, cada producto referencia una unidad existente mediante `id_unidad_medida`.

Esto permite mantener la consistencia de los nombres y abreviaturas de las unidades.

---


## 4. Resultado final

Luego del proceso de normalización, el modelo quedó dividido en entidades con responsabilidades específicas:

| Entidad | Responsabilidad |
|---|---|
| `persona` | Datos personales |
| `usuario` | Datos de acceso y relación con persona/rol |
| `rol` | Roles del sistema |
| `venta` | Información general de la venta |
| `detalle_venta` | Productos incluidos en una venta |
| `producto` | Información de los productos |
| `categoria` | Clasificación de productos |
| `medio_de_pago` | Información general del medio de pago |
| `tarjeta` | Información específica de tarjetas |
| `banco` | Información de bancos |
| `unidad_medida` | Catálogo de unidades de medida |

De esta manera, el modelo final presenta **menor redundancia**, mayor **integridad referencial**, una mejor separación de responsabilidades y mayor facilidad para realizar modificaciones sin generar inconsistencias.


**CAMBIOS REALIZADOS A LAS TABLAS**:

* Cambio en el nombre, pasando de nombres en plural a singular.  
* En **detalle_venta**: Se eliminó la clave primaria simple **id_detalle,** ahora la clave primaria pasa a ser la combinación entre **id_producto** y **id_venta**, esto refleja mejor el funcionamiento de la tabla.  
* Se cambió el nombre del atributo **kilogramo** a **peso** en la tabla **producto**, para que tenga sentido la existencia de la entidad **unidad_medida** y se puedan trabajar con unidades distintas al kilo (gramos, mililitros etc).
* Se separo **banco** de **tarjeta** para cumplir con la 3FN ademas de
* Se separo **unidad_medida** de **producto** para cumplir con la 3FN y evitar redundancia.