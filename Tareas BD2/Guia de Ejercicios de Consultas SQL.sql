-- Ejercicio 1: Liste todos los clientes que no tienen órdenes de venta
SELECT id, name
FROM res_partner
WHERE id NOT IN (SELECT partner_id FROM sale_order);

-- Ejercicio 2: Encuentre todos los clientes que no tienen identidad (vat)
-- y actualicelos agregándoles el texto NO DISPONIBLE como identidad
select * from res_partner where vat is null;

UPDATE res_partner
SET vat = 'NO DISPONIBLE'
WHERE vat IS NULL;

select * from res_partner where vat = 'NO DISPONIBLE';

-- Ejercicio 3: Agregue una columna puntos a res.partner
ALTER TABLE res_partner
ADD COLUMN puntos FLOAT;

select puntos., * from res_partner;

-- Ejercicio 4: Actualice la tabla res.partner calculando la cantidad de puntos ganados por los clientes
UPDATE res_partner AS p
SET puntos = (
    SELECT COALESCE(SUM((ol.price_subtotal * 0.1)), 0)
    FROM sale_order AS o
    JOIN sale_order_line AS ol ON o.id = ol.order_id
    WHERE o.partner_id = p.id
);

select puntos, * from res_partner order by puntos desc;

-- Ejercicio 5: Para una orden (sale.order) que tenga impuestos; vía sql quítele los impuestos
select amount_tax, * from sale_order;

UPDATE sale_order
SET amount_tax = 0
WHERE id = (SELECT id FROM sale_order WHERE amount_tax > 0 LIMIT 1);

-- Ejercicio 6: Para una orden (sale.order) que no tenga impuestos; vía sql agregale los impuestos
UPDATE sale_order
SET amount_tax = 100
WHERE id = (SELECT id FROM sale_order WHERE amount_tax = 0 LIMIT 1);

select amount_tax, * from sale_order;

-- Ejercicio 7: Para una orden (sale.order); cambie la moneda
select id from res_currency where name = 'USD';

UPDATE sale_order
SET currency_id = 2
WHERE currency_id = (SELECT id FROM res_currency where name = 'HNL');

-- malo
-- Ejercicio 8: Liste todos los productos que no tienen impuestos
SELECT id, name
FROM product_template
WHERE id NOT IN (SELECT product_tmpl_id FROM product_taxes_rel);


-- Ejercicio 9: Liste todos los productos que no tienen ningún tipo de movimiento
SELECT id, name
FROM product_template
WHERE id NOT IN (
    SELECT product_tmpl_id
    FROM stock_move_line
    UNION
    SELECT product_id
    FROM stock_move
);

-- Ejercicio 10: Busque cual es el producto más vendido
SELECT product_id, COUNT(*) AS total_sold
FROM sale_order_line
GROUP BY product_id
ORDER BY total_sold DESC
LIMIT 1;

-- Ejercicio 11: Busque cual es el segundo producto más vendido
SELECT product_id, COUNT(*) AS total_sold
FROM sale_order_line
GROUP BY product_id
ORDER BY total_sold DESC
LIMIT 1 OFFSET 1;


-- Ejercicio 12: Dado un producto en product.template; y el movimiento de este en stock.move.line; haga una consulta en la que agregue una columna; que ponga la cantidad con signo
SELECT 
    sm.id, 
    sm.product_id, 
    sm.product_qty * CASE WHEN sm.location_dest_id = p.location_id THEN 1 ELSE -1 END AS cantidad_con_signo
FROM stock_move_line AS sm
JOIN product_product AS p ON sm.product_id = p.id
WHERE p.id = (SELECT id FROM product_template LIMIT 1);


-- Ejercicio 13: Usando el resultado del ejercicio anterior; muestra la cantidad actual de los productos
SELECT product_id, SUM(cantidad_con_signo) AS cantidad_actual
FROM (
    SELECT 
        sm.id, 
        sm.product_id, 
        sm.product_qty * CASE WHEN sm.location_dest_id = p.location_id THEN 1 ELSE -1 END AS cantidad_con_signo
    FROM stock_move_line AS sm
    JOIN product_product AS p ON sm.product_id = p.id
    WHERE p.id = (SELECT id FROM product_template LIMIT 1)
) AS movimientos
GROUP BY product_id;