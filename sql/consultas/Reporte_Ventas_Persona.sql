-- REPORTE DE VENTAS POR CAJERO

DECLARE @FechaInicioCaj DATE = '2026-02-01';
DECLARE @FechaFinCaj DATE = '2026-02-28';

SELECT 
    p.apellido + ', ' + p.nombre AS 'Cajero',
    COUNT(DISTINCT v.id_venta) AS 'Tickets_Atendidos',
    SUM(dv.cantidad) AS 'Total_Unidades_Vendidas',
    SUM(dv.subtotal) AS 'Ingreso_Total_Cajero',
    SUM(dv.subtotal) * 1.0 / COUNT(DISTINCT v.id_venta) AS 'Ticket_Promedio'
FROM 
    venta v
INNER JOIN 
    detalle_venta dv ON v.id_venta = dv.id_venta
INNER JOIN 
    usuario u ON v.id_persona = u.id_persona
INNER JOIN 
    persona p ON u.id_persona = p.id_persona
WHERE 
    v.estado = 'Completada'
    AND v.creado_en >= @FechaInicioCaj 
    AND v.creado_en < DATEADD(DAY, 1, @FechaFinCaj)
GROUP BY 
    u.id_persona, p.apellido, p.nombre
ORDER BY 
    Ingreso_Total_Cajero DESC;