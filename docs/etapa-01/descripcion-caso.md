# Sistema de Punto de Venta para Supermercado de Sucursal Única

## Descripción Completa del Caso

El sistema es una aplicación de escritorio diseñada para una marca de supermercado que opera en una única sucursal. Su propósito principal es informatizar las operaciones diarias del punto de venta:
- Registro de compras.
- Gestión de inventario.
- Administración de usuarios.

---

### Roles de Usuario y Permisos

El sistema contempla cuatro roles con responsabilidades y accesos bien diferenciados:

1. **Cajero**
   - Registra las compras escaneando o ingresando manualmente el código de barras de cada producto.
   - Genera el ticket de compra.
   - El stock se actualiza automáticamente al finalizar la transacción (no puede modificarlo manualmente).
   - *Consideraciones:* Un cajero puede registrar múltiples compras, pero cada compra está asociada a un único cajero y se abona con un solo medio de pago. Una venta está formada por varios productos y un mismo producto puede aparecer en varias ventas.

2. **Personal de Inventario**
   - Mantiene el catálogo general.
   - Crea, elimina y modifica productos y categorías.
   - *Consideraciones:* Una categoría puede agrupar muchos productos, pero cada producto pertenece a una sola categoría.

3. **Administración**
   - Gestiona las cuentas de usuario del sistema (altas, bajas y modificación de roles).
   - Asigna a cada usuario un único rol y lo vincula a una sola persona física.

4. **Supervisor de Caja**
   - Interviene para autorizar y corregir errores puntuales en las transacciones en curso.
   - Puede eliminar productos registrados por error en la lista activa del cajero.

---

### Consideraciones de Integridad y Trazabilidad

- **Historial de Precios:** Cada venta registra el precio unitario vigente al momento exacto de la transacción, asegurando un historial fidedigno que no se altera ante futuros aumentos o disminuciones de precio.
- **Auditoría de Ventas:** Toda venta queda vinculada de forma obligatoria al medio de pago utilizado y al cajero que procesó la operación.
- **Bajas Lógicas:** La eliminación de usuarios, productos y categorías se efectúa mediante borrado lógico, garantizando la preservación de la integridad referencial y el histórico de transacciones.