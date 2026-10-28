# Proyecto - Base de Datos I - Equipo 44

Este es el repositorio de nuestro proyecto para la asignatura de BDI.
A continuacion podran encontrar quienes componen este grupo, como se estructura el proyecto y un indice para poder acceder a la documentacion.

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
  - [Etapa 5: Triggers, Auditoría e Índices](docs/etapa-05/)
    - [Triggers de auditoría](docs/etapa-05/triggers-auditoria.md)
    - [Índices y optimización de consultas](docs/etapa-05/indices-optimizacion.md)
- [SQL](sql/)
  - [DDL: creación de la base de datos](sql/ddl/)
  - [DML: datos de prueba](sql/dml/)
  - [Consultas](sql/consultas/)
  - [Tablas de auditoría y triggers](sql/tecnico/triggers/)
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
│   └── etapa-05/          # Triggers, auditoria e indices
├── sql/
│   ├── ddl/               # Creacion de la base de datos y sus tablas
│   ├── dml/               # Datos de prueba y validacion de restricciones
│   ├── consultas/         # Consultas avanzadas implementadas
│   └── tecnico/
│       ├── triggers/      # Tablas de auditoria y triggers
│       └── indices/       # Carga masiva y prueba de indices
└── README.md
```

## Etapas del proyecto

| Etapa | Contenido | Documentación | Scripts |
| --- | --- | --- | --- |
| 1 | Requerimientos y dominio del negocio | [docs/etapa-01](docs/etapa-01/) | - |
| 2 | Modelado conceptual y lógico | [docs/etapa-02](docs/etapa-02/) | - |
| 3 | Restricciones de integridad | [docs/etapa-03](docs/etapa-03/) | [sql/ddl/crear_bd.sql](sql/ddl/crear_bd.sql) |
| 4 | Consultas avanzadas | [docs/etapa-04](docs/etapa-04/) | [sql/consultas](sql/consultas/) |
| 5 | Triggers, auditoría e índices | [docs/etapa-05](docs/etapa-05/) | [sql/tecnico](sql/tecnico/) |

## Puesta en marcha

Los scripts se ejecutan en SQL Server en el siguiente orden:

1. [sql/ddl/crear_bd.sql](sql/ddl/crear_bd.sql): crea la base de datos y todas las tablas con sus restricciones.
2. [sql/dml/datos_prueba.sql](sql/dml/datos_prueba.sql): inserta los datos de prueba y valida las restricciones.
3. [sql/tecnico/triggers/tablas_auditoria.sql](sql/tecnico/triggers/tablas_auditoria.sql): crea las tablas de auditoría (ejecutar sobre `supermercado_db`).
4. [sql/tecnico/triggers/triggers_auditoria.sql](sql/tecnico/triggers/triggers_auditoria.sql): crea los triggers de auditoría (ejecutar sobre `supermercado_db`).
5. [sql/tecnico/indices/01_carga_masiva.sql](sql/tecnico/indices/01_carga_masiva.sql): carga las 1.000.000 de filas de la prueba de índices (opcional, tarda unos minutos). Después se corren los scripts `02` a `06` en orden y `07_limpieza.sql` borra las tablas de prueba.

> Los inserts marcados como "DEBE FALLAR" en `datos_prueba.sql` están comentados a propósito: sirven para verificar que las restricciones funcionan. Descomentar solo para probar cada caso.
