#items with discount
def total_revenue_after_discount(invoice_id)
  total = 0.00
  result = Invoice.find_by_sql([
  "SELECT 
  SUM(max_discount_calculation) AS total_discount
FROM (
  SELECT 
      invoice_items.item_id,
      MIN(CASE 
              WHEN invoice_items.quantity >= discounts.quantity_threshold THEN
                  invoice_items.quantity * items.unit_price * 0.01 * ((100 - discounts.percentage_discount) / 100)
              ELSE 
                  0
          END) AS max_discount_calculation
  FROM 
      items
      INNER JOIN invoice_items ON items.id = invoice_items.item_id
      INNER JOIN merchants ON merchants.id = items.merchant_id
      INNER JOIN discounts ON discounts.merchant_id = merchants.id
  WHERE 
      invoice_items.invoice_id = 294
      AND invoice_items.quantity >= discounts.quantity_threshold
  GROUP BY 
      invoice_items.item_id
) AS subquery"
      ])
  total += result.pluck(:total_discount).first

  no_discount_result = Invoice.find_by_sql([
  "SELECT 
    SUM(min_discount) AS total_min_discount
FROM (
    SELECT 
        invoice_items.item_id, 
        MIN(
            CASE 
                WHEN invoice_items.quantity < discounts.quantity_threshold 
                THEN invoice_items.quantity * items.unit_price * (discounts.percentage_discount * 0.01)
                ELSE 0
            END
        ) AS min_discount
    FROM 
        items
        INNER JOIN invoice_items ON items.id = invoice_items.item_id
        INNER JOIN merchants ON merchants.id = items.merchant_id
        INNER JOIN discounts ON discounts.merchant_id = merchants.id
    WHERE 
        invoice_items.invoice_id = 294
    GROUP BY 
        invoice_items.item_id
) AS min_discounts_summary;"

  total += no_discount_result.pluck(:total_min_discount).first
  total
end