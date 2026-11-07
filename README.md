# Proyecto - Base de Datos I - Equipo 44

Este repositorio contiene el desarrollo del proyecto práctico integrador para la asignatura **Base de Datos I**.

## Descripción General del Proyecto

El proyecto consiste en el diseño, modelado e implementación integral de la base de datos relacional para un **Sistema de Punto de Venta (POS) e Inventario de un Supermercado de Sucursal Única**. 

El sistema centraliza las operaciones diarias del negocio: registro de ventas en línea de caja, soporte para múltiples medios de pago, control de inventario con actualización automática de existencias, preservación del historial de precios de venta, gestión de usuarios bajo un esquema de seguridad basado en roles (Cajero, Personal de Inventario, Supervisor de Caja y Administrador) y mecanismos de auditoría mediante triggers y bajas lógicas.

### Objetivo del Sistema

El objetivo principal es proveer una solución de base de datos que:
- **Garantice la integridad y consistencia de los datos** a través de restricciones y transacciones.
- **Optimice la operatoria transaccional diaria** mediante procedimientos almacenados.
- **Asegure la trazabilidad y auditoría de la información sensible**, registrando modificaciones críticas y evitando eliminaciones físicas destructivas mediante borrado lógico.
- **Aplique reglas de seguridad estrictas**, definiendo roles y permisos estrictamente acotados a las responsabilidades de cada puesto operativo.

---

## Integrantes:

- Harvey Benjamin
- Rojas Marcos Agustin
- Sanchez Cueba Tobias Agustin
- Santoro Sandoval Lionel Adolfo
- Hardoy Juan Segundo

## Índice

- [Docs](docs/)
  - [Etapa 1: Requerimientos y Dominio del Negocio](docs/etapa-01/)
    - [Descripción del caso](docs/etapa-01/descripcion-caso.md)
    - [Alcance](docs/etapa-01/alcance.md)
    - [Reglas de negocio](docs/etapa-01/reglas-negocio.md)
  - [Etapa 2: Modelado Conceptual y Lógico](docs/etapa-02/)
    - [DER (conceptual y fuente)](docs/etapa-02/der/)
    - [Decisiones de diseño](docs/etapa-02/decisiones-disenio.md)
    - [Normalización](docs/etapa-02/normalizacion.md)
  - [Etapa 3: Restricciones de Integridad](docs/etapa-03/)
    - [Restricciones de integridad](docs/etapa-03/restricciones-integridad.md)
  - [Etapa 4: Consultas Avanzadas](docs/etapa-04/)
    - [Consulta avanzada](docs/etapa-04/consulta-avanzada.md)
  - [Etapa 5: Implementación Técnica Avanzada](docs/etapa-05/)
    - [Triggers de auditoría](docs/etapa-05/triggers-auditoria.md)
    - [Transacciones](docs/etapa-05/transacciones.md)
    - [Objetivos de procedimientos y funciones almacenadas](docs/etapa-05/objetivos_procedimientos_y_funciones_almacenadas.md)
    - [Comparativa de procedimientos y funciones](docs/etapa-05/comparativa_procedimientos_funciones.md)
    - [Seguridad, roles y permisos](docs/etapa-05/seguridad.md)
    - [Índices y optimización de consultas](docs/etapa-05/indices-optimizacion.md)
- [SQL](sql/)
  - [DDL: creación de la base de datos](sql/ddl/)
  - [DML: datos de prueba](sql/dml/)
  - [Consultas](sql/consultas/)
  - [Técnico](sql/tecnico/)
    - [Tablas de auditoría y triggers](sql/tecnico/triggers/)
    - [Transacciones](sql/tecnico/transacciones/)
    - [Procedimientos y funciones almacenadas](sql/tecnico/procedimientos_funciones/)
    - [Seguridad y roles](sql/tecnico/seguridad/)
    - [Prueba de índices](sql/tecnico/indices/)

## Estructura del Proyecto

```text
proyecto-bd1-equipo-44/
├── docs/
│   ├── etapa-01/          # Requerimientos y dominio del negocio
│   ├── etapa-02/          # Modelado conceptual y logico
│   │   └── der/           # Diagramas entidad-relacion (conceptual y fuente)
│   ├── etapa-03/          # Restricciones de integridad
│   ├── etapa-04/          # Consultas avanzadas
│   └── etapa-05/          # Triggers, auditoria, transacciones, SPs/funciones, seguridad e indices
├── sql/
│   ├── ddl/               # Creacion de la base de datos y sus tablas
│   ├── dml/               # Datos de prueba y validacion de restricciones
│   ├── consultas/         # Consultas avanzadas implementadas
│   └── tecnico/
│       ├── triggers/      # Tablas de auditoria y triggers
│       ├── transacciones/ # Creacion y prueba de uso de transacciones
│       ├── procedimientos_funciones/ # Procedimientos y funciones almacenadas
│       ├── seguridad/     # Configuracion de seguridad, usuarios y roles
│       └── indices/       # Pruebas de rendimiento y optimizacion con indices
└── README.md
```

## Etapas del proyecto

| Etapa | Contenido | Documentación | Scripts |
| --- | --- | --- | --- |
| 1 | Requerimientos y dominio del negocio | [docs/etapa-01](docs/etapa-01/) | - |
| 2 | Modelado conceptual y lógico | [docs/etapa-02](docs/etapa-02/) | - |
| 3 | Restricciones de integridad | [docs/etapa-03](docs/etapa-03/) | [sql/ddl/crear_bd.sql](sql/ddl/crear_bd.sql), [sql/dml/datos_prueba.sql](sql/dml/datos_prueba.sql) |
| 4 | Consultas avanzadas | [docs/etapa-04](docs/etapa-04/) | [sql/consultas](sql/consultas/) |
| 5 | Triggers, auditoría, transacciones, procedimientos y funciones almacenadas, seguridad e índices | [docs/etapa-05](docs/etapa-05/) | [sql/tecnico](sql/tecnico/) |

## Puesta en marcha

Los scripts se ejecutan en SQL Server en el siguiente orden:

1. [sql/ddl/crear_bd.sql](sql/ddl/crear_bd.sql): crea la base de datos y todas las tablas con sus restricciones.
2. [sql/dml/datos_prueba.sql](sql/dml/datos_prueba.sql): inserta los datos de prueba y valida las restricciones.
3. [sql/tecnico/triggers/tablas_auditoria.sql](sql/tecnico/triggers/tablas_auditoria.sql): crea las tablas de auditoría.
4. [sql/tecnico/triggers/triggers_auditoria.sql](sql/tecnico/triggers/triggers_auditoria.sql): crea los triggers de auditoría.
5. [sql/tecnico/procedimientos_funciones/](sql/tecnico/procedimientos_funciones/): scripts `01` a `04` para la lógica encapsulada y funciones auxiliares.
6. [sql/tecnico/transacciones/transacciones.sql](sql/tecnico/transacciones/transacciones.sql): pruebas y lógica transaccional.
7. [sql/tecnico/seguridad/seguridad_permisos_roles.sql](sql/tecnico/seguridad/seguridad_permisos_roles.sql): aprovisionamiento de logins, roles y permisos de base de datos.
8. [sql/tecnico/indices/01_carga_masiva.sql](sql/tecnico/indices/01_carga_masiva.sql): carga las 1.000.000 de filas de una tabla de prueba para la demostracion del uso de índices. Después se corren los scripts `02` a `06` en orden y `07_limpieza.sql` borra las tablas de prueba.

> Los inserts marcados como "DEBE FALLAR" en `datos_prueba.sql` están comentados a propósito: sirven para verificar que las restricciones funcionan. Descomentar solo para probar cada caso.
