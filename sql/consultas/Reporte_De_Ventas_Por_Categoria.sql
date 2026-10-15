-- Reporte de Ventas por Categoría

DECLARE @FechaInicioCat DATETIME = '2026-02-01 00:00:00';
DECLARE @FechaFinCat DATETIME = '2026-02-28 23:59:59';

SELECT 
    cat.nombre AS 'Categoria',
    COUNT(DISTINCT v.id_venta) AS 'Tickets_Con_Esta_Categoria',
    SUM(dv.cantidad) AS 'Total_Unidades_Vendidas',
    SUM(dv.subtotal) AS 'Ingreso_Total_Categoria'
FROM 
    venta v
INNER JOIN 
    detalle_venta dv ON v.id_venta = dv.id_venta
INNER JOIN 
    producto prod ON dv.id_producto = prod.id_producto
INNER JOIN 
    categoria cat ON prod.id_categoria = cat.id_categoria
WHERE 
    v.estado = 'Completada'
    AND v.creado_en >= @FechaInicioCat 
    AND v.creado_en <= @FechaFinCat
GROUP BY 
    cat.nombre
ORDER BY 
    Ingreso_Total_Categoria DESC;
