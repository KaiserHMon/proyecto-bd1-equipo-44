-- Analisis de Ingresos por Banco y Tarjeta

SELECT 
    b.nombre AS Banco,
    t.tipo_tarjeta AS Tipo_Tarjeta,
    t.marca_tarjeta AS Marca,
    COUNT(v.id_venta) AS Cantidad_Ventas,
    SUM(v.monto_total) AS Ingreso_Total
FROM tarjeta t
INNER JOIN medio_de_pago mp ON t.id_medio_pago = mp.id_medio_pago
INNER JOIN banco b ON t.id_banco = b.id_banco
INNER JOIN venta v ON mp.id_medio_pago = v.id_medio_pago
WHERE v.estado = 'Completada'
  AND mp.eliminado_en IS NULL
GROUP BY 
    b.nombre, 
    t.tipo_tarjeta, 
    t.marca_tarjeta
HAVING SUM(v.monto_total) >= 5000
ORDER BY Ingreso_Total DESC;