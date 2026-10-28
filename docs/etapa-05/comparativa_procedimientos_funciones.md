# Comparativa de Eficiencia: Consultas Directas vs. Procedimientos y Funciones

Informe comparativo sobre cómo responde el motor de base de datos **SQL Server Express** al trabajar con consultas directas frente al uso de procedimientos y funciones almacenadas.

---

## 1. Puntos que influyen en el rendimiento

Para evaluar la eficiencia entre cada método, se analizan los siguientes aspectos:
1. **Compilación de consultas:** El tiempo que tarda el motor en revisar la sintaxis y decidir cómo buscar los datos (plan de ejecución).
2. **Uso de la red:** La cantidad de texto y datos que viajan entre el programa cliente y la base de datos.
3. **Mantenimiento y seguridad:** Qué tan fácil es proteger las tablas y evitar errores o inyecciones de código.
4. **Cálculos masivos:** Cómo se comporta la base de datos cuando debe procesar miles de registros.

---

## 2. Cuadro comparativo

| Criterio | Consultas Directas (`INSERT`, `UPDATE`) | Procedimientos Almacenados (`SP`) | Funciones Almacenadas (`UDF`) |
| :--- | :--- | :--- | :--- |
| **Plan de ejecución** | El motor suele tener que analizar la consulta cada vez que cambia un parámetro. | Se compila en la primera llamada y el plan queda guardado en memoria para las siguientes. | Se compilan, pero las funciones escalares pueden procesar los datos fila por fila si no están optimizadas. |
| **Tráfico de red** | **Alto.** Se debe enviar toda la sentencia SQL completa en cada operación. | **Bajo.** Solo se envía el nombre del procedimiento y sus parámetros. | **Bajo a moderado.** Viajan como parte de la consulta `SELECT`. |
| **Carga de datos por lotes** | Rápido si se hace en una sola sentencia; lento si la aplicación manda muchas consultas sueltas. | **Muy eficiente.** Permite agrupar validaciones y pasos sin idas y vueltas con la aplicación. | No aplica para inserciones o modificaciones; solo se usa para calcular o consultar. |
| **Seguridad** | Exige dar permisos directos sobre las tablas, lo que deja expuesta la estructura. | **Máxima.** Se puede dar permiso solo para ejecutar el procedimiento, protegiendo las tablas. | Permite centralizar cálculos, pero requiere acceso de lectura sobre los datos. |

---

## 3. Conclusiones prácticas

* **Para insertar, modificar o dar de baja registros:**  
  Los **Procedimientos Almacenados** son la mejor opción. Reducen el tráfico de la red, aprovechan los planes de ejecución en memoria y evitan que la aplicación tenga acceso directo a modificar las tablas.

* **Para cálculos y consultas repetitivas:**  
  Las **Funciones Almacenadas** son útiles para evitar duplicar fórmulas matemáticas o filtros en varios lugares. No obstante, deben usarse con criterio en tablas muy grandes para no ralentizar las consultas generales.

* **Recomendación general:**  
  En nuestro caso, el sistema de supermercado, las operaciones operativas (crear un producto, procesar un cobro o dar de baja un artículo) deben delegarse a **procedimientos almacenados**, mientras que los cálculos de precios o consultas puntuales de totales se resuelven con **funciones**.