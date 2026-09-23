# Evolución del Modelo de Datos: Del Concepto a la Implementación

## 1. Visión General
Este documento detalla la trayectoria evolutiva del diseño de base de datos para el sistema de punto de venta, abarcando desde la descripción inicial de las reglas de negocio hasta la consolidación de un esquema relacional normalizado. El objetivo es proporcionar una trazabilidad clara de cómo los requerimientos funcionales se transformaron en estructuras de datos eficientes, resaltando las decisiones arquitectónicas clave y los procesos de refinamiento técnico que garantizan la integridad, escalabilidad y coherencia del sistema.

## 2. Decisiones Arquitectónicas Iniciales
El diseño comenzó con la interpretación de las Reglas de Negocio (RN) fundamentales, las cuales sentaron las bases para la gestión de usuarios, la persistencia de datos y la auditoría histórica.

* **Roles y Permisos (RN.01, RN.02, RN.11):** Para garantizar un control de acceso robusto, se implementó una jerarquía lineal estricta. Cada individuo en el sistema se registra como una `Persona`, que a su vez posee una única cuenta de `Usuario` vinculada a un `Rol` específico. Esta estructura de 1 Persona -> 1 Usuario -> 1 Rol simplifica la administración de permisos y asegura que las responsabilidades dentro del sistema estén claramente delimitadas.
* **Baja Lógica (RN.06):** En lugar de eliminar registros físicamente de la base de datos, se adoptó la estrategia de "Baja Lógica". Mediante el uso de atributos como `eliminado_en` o un flag de eliminado, el sistema preserva la integridad referencial y permite mantener un histórico completo de las operaciones, facilitando auditorías posteriores sin perder la capacidad de filtrar datos activos para la operación diaria.
* **Inmutabilidad Histórica (RN.04):** Para proteger la validez de los reportes financieros, se decidió almacenar el `precio_unitario` directamente en la tabla `Detalle_Venta` al momento de la transacción. Esto evita que cambios futuros en el catálogo de precios alteren retroactivamente el valor de ventas ya realizadas, garantizando que el registro sea una fotografía fiel de la transacción en su contexto temporal.

## 3. Del Modelo Conceptual al Relacional (Normalización)
La transición del Diagrama Entidad-Relación (DER) conceptual al modelo físico requirió un proceso de normalización para eliminar redundancias y mejorar la flexibilidad del esquema.

### 3.1. Tratamiento del Medio de Pago
* **Problema Inicial:** El modelo original no distinguía adecuadamente entre los diversos tipos de pagos, lo que generaba campos vacíos (nulls) cuando un pago no era mediante tarjeta.
* **Solución Relacional:** Se abstrajo la entidad `medio_de_pago` para manejar información común (tipo, marca de tiempo).
* **Normalización:** Se extrajeron los detalles específicos del plástico a una entidad independiente denominada `tarjeta` (número, fecha de vencimiento, id_banco). Esto asegura que los datos de tarjetas solo existan cuando el medio de pago lo requiera, cumpliendo con las formas normales de base de datos.

### 3.2. Gestión de Estados en Ventas
* **Corrección:** Se eliminó el atributo `id_anulacion` que se encontraba originalmente en la entidad `venta`.
* **Justificación:** Se determinó que dicho atributo era redundante. La trazabilidad del ciclo de vida de una venta (Activa, Completada, Anulada) se gestiona de manera más eficiente mediante el atributo `estado`. Esta simplificación reduce la complejidad de las consultas y evita inconsistencias de estado.

### 3.3. Trazabilidad y Auditoría
* **Mejora:** Se integraron atributos de auditoría global en todas las entidades críticas del sistema.
* **Implementación:** La inclusión de campos como `creado_en`, `actualizado_en` y `eliminado_en` permite un seguimiento detallado del ciclo de vida de cada registro. Esta decisión técnica responde a la necesidad de saber no solo qué datos existen, sino cuándo y quién realizó modificaciones o eliminaciones lógicas, fortaleciendo la seguridad del sistema.

### 3.4. Relaciones de Catálogo
* **Estructura:** Siguiendo la RN.12, se optimizó la relación entre `producto` y sus atributos descriptivos. Se reemplazaron los campos de texto libre por llaves foráneas (FK) hacia entidades maestras como `categoria` y `unidad_medida`. Esta normalización previene errores de entrada de datos y facilita la generación de reportes categorizados y el control de inventario preciso.

