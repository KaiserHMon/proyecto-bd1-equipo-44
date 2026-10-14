-- Analisis de Productos Mas Vendidos por Categoria

SELECT 
    c.nombre AS categoria,
    p.nombre AS producto,
    p.stock AS stock_actual,
    SUM(dv.cantidad) AS total_unidades_vendidas,
    SUM(dv.subtotal) AS ingreso_total_generado
FROM 
    categoria c
INNER JOIN 
    producto p ON c.id_categoria = p.id_categoria
INNER JOIN 
    detalle_venta dv ON p.id_producto = dv.id_producto
INNER JOIN 
    venta v ON dv.id_venta = v.id_venta
WHERE 
    v.estado = 'Completada' -- Revisamos que su estado de venta sea completado
    AND p.eliminado_en IS NULL -- Revisamos que no esten borrados (el borrado es logico)
GROUP BY 
    c.id_categoria, 
    c.nombre,
    p.id_producto,
    p.nombre, 
    p.stock
HAVING 
    SUM(dv.cantidad) >= 1 -- Es la cantidad minima de ventas que tiene que tener
ORDER BY 
    ingreso_total_generado DESC;