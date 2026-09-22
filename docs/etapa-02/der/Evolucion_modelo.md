# Evolución del Modelo de Datos: Del Concepto a la Implementación

## 1. Visión General
Este documento detalla la trayectoria evolutiva del diseño de base de datos para el sistema de punto de venta, abarcando desde la descripción inicial de las reglas de negocio hasta la consolidación de un esquema relacional normalizado. El objetivo es proporcionar una trazabilidad clara de cómo los requerimientos funcionales se transformaron en estructuras de datos eficientes, resaltando las decisiones arquitectónicas clave y los procesos de refinamiento técnico que garantizan la integridad, escalabilidad y coherencia del sistema.

## 2. Decisiones Arquitectónicas Iniciales
El diseño comenzó con la interpretación de las Reglas de Negocio (RN) fundamentales, las cuales sentaron las bases para la gestión de usuarios, la persistencia de datos y la auditoría histórica.

* **Roles y Permisos (RN.01, RN.02, RN.11):** Para garantizar un control de acceso robusto, se implementó una jerarquía lineal estricta. Cada individuo en el sistema se registra como una `Persona`, que a su vez posee una única cuenta de `Usuario` vinculada a un `Rol` específico. Esta estructura de 1 Persona -> 1 Usuario -> 1 Rol simplifica la administración de permisos y asegura que las responsabilidades dentro del sistema estén claramente delimitadas.
* **Baja Lógica (RN.06):** En lugar de eliminar registros físicamente de la base de datos, se adoptó la estrategia de "Baja Lógica". Mediante el uso de atributos como `eliminado_en` o un flag de eliminado, el sistema preserva la integridad referencial y permite mantener un histórico completo de las operaciones, facilitando auditorías posteriores sin perder la capacidad de filtrar datos activos para la operación diaria.
* **Inmutabilidad Histórica (RN.04):** Para proteger la validez de los reportes financieros, se decidió almacenar el `precio_unitario` directamente en la tabla `Detalle_Venta` al momento de la transacción. Esto evita que cambios futuros en el catálogo de precios alteren retroactivamente el valor de ventas ya realizadas, garantizando que el registro sea una fotografía fiel de la transacción en su contexto temporal.
