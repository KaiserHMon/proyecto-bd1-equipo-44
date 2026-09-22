Evolución del Modelo de Datos: De la Idea Inicial al Modelo Relacional

Este documento detalla la evolución de la arquitectura de datos del sistema de gestión de supermercado, desde el planteo inicial de las reglas de negocio hasta llegar al Modelo Relacional Normalizado.

0. Análisis del Planteo Inicial

El requerimiento original solicitaba informatizar un punto de venta gestionando Usuarios (Roles), Inventario (Productos y Categorías) y Ventas.

Las Reglas de Negocio (RN) más críticas que moldearon el diseño inicial fueron:

RN.04: Mantener el precio unitario histórico en cada venta.

RN.06: Implementar bajas lógicas para preservar la integridad referencial.

RN.10 & RN.11: Relación estricta entre Persona e Usuario (1:1) y Rol con Usuario (1:N).

RN.15: Relación de muchos a muchos (N:M) entre Ventas y Productos.

1. Primera Fase: El Modelo Entidad-Relación (DER Conceptual)

Al volcar las reglas a un diagrama conceptual (DER), tomamos las siguientes decisiones arquitectónicas:

Jerarquía y Herencia (Persona - Usuario): Se identificó que un Usuario es una Persona con credenciales de acceso. Se modeló utilizando una especialización disjunta, separando los datos personales (nombre, apellido, correo) de los datos de acceso (nombre_usuario, contraseña, código de autorización).

Resolución de N:M (Detalle Venta): La relación entre Venta y Producto se conceptualizó con atributos propios (cantidad, precio_unitario, subtotal). El campo precio_unitario aquí garantiza el cumplimiento de la RN.04 (historial de precios intacto).

Medios de Pago: Inicialmente, los datos bancarios (tarjeta, banco, nro_tarjeta) se modelaron como atributos de la entidad Medio_pago.

Bajas Lógicas: Se agregó un atributo booleano eliminado en entidades clave (Persona, Categoria, Producto) para cumplir la RN.06.
