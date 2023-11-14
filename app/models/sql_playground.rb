SELECT discounts.*, invoice_items.*
    FROM items
    INNER JOIN invoice_items ON items.id = invoice_items.item_id
    INNER JOIN merchants ON merchants.id = items.merchant_id
    INNER JOIN discounts ON discounts.merchant_id = merchants.id
    WHERE invoice_items.invoice_id = 294
    ORDER BY discounts.id desc;

    SELECT 
    discounts.percentage_discount, 
    discounts.quantity_threshold, 
    invoice_items.quantity, 
    invoice_items.item_id, 
    items.unit_price,
    CASE 
        WHEN invoice_items.quantity >= discounts.quantity_threshold THEN
            invoice_items.quantity * items.unit_price * 0.01 * ((100 - discounts.percentage_discount) / 100)
        ELSE 
            NULL
    END AS discount_calculation
FROM 
    items
    INNER JOIN invoice_items ON items.id = invoice_items.item_id
    INNER JOIN merchants ON merchants.id = items.merchant_id
    INNER JOIN discounts ON discounts.merchant_id = merchants.id
WHERE 
    invoice_items.invoice_id = 294
    AND invoice_items.quantity >= discounts.quantity_threshold
GROUP BY 
    discounts.percentage_discount, 
    discounts.quantity_threshold, 
    invoice_items.quantity, 
    invoice_items.item_id, 
    discounts.id, 
    items.unit_price
ORDER BY 
    discounts.id DESC;

    # this one has just the discount_calculation column
    SELECT discount_calculation
FROM (
    SELECT 
        discounts.percentage_discount, 
        discounts.quantity_threshold, 
        invoice_items.quantity, 
        invoice_items.item_id, 
        items.unit_price,
        CASE 
            WHEN invoice_items.quantity >= discounts.quantity_threshold THEN
                invoice_items.quantity * items.unit_price * 0.01 * ((100 - discounts.percentage_discount) / 100)
            ELSE 
                NULL
        END AS discount_calculation
    FROM 
        items
        INNER JOIN invoice_items ON items.id = invoice_items.item_id
        INNER JOIN merchants ON merchants.id = items.merchant_id
        INNER JOIN discounts ON discounts.merchant_id = merchants.id
    WHERE 
        invoice_items.invoice_id = 294
        AND invoice_items.quantity >= discounts.quantity_threshold
    GROUP BY 
        discounts.percentage_discount, 
        discounts.quantity_threshold, 
        invoice_items.quantity, 
        invoice_items.item_id, 
        discounts.id, 
        items.unit_price
    ORDER BY 
        discounts.id DESC
) AS subquery;

#this one filters to sort for smallest percentage_discount
WITH DiscountCalculations AS (
SELECT 
    discounts.percentage_discount, 
    discounts.quantity_threshold, 
    invoice_items.quantity, 
    invoice_items.item_id, 
    items.unit_price,
    CASE 
        WHEN invoice_items.quantity < discounts.quantity_threshold THEN
            invoice_items.quantity * items.unit_price * 0.01
        ELSE 
            NULL
    END AS discount_calculation
FROM 
    items
    INNER JOIN invoice_items ON items.id = invoice_items.item_id
    INNER JOIN merchants ON merchants.id = items.merchant_id
    INNER JOIN discounts ON discounts.merchant_id = merchants.id
WHERE 
    invoice_items.invoice_id = 294
    AND invoice_items.quantity < discounts.quantity_threshold
    AND discounts.percentage_discount = (
        SELECT MIN(quantity_threshold)
        FROM discounts
        WHERE merchant_id = merchants.id)
    )
SELECT SUM(discount_calculation) from DiscountCalculations;