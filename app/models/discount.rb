class Discount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant

  validates :percentage_discount, presence: true
  validates :quantity_threshold, presence: true
  validates :name, presence: true
  validates :merchant_id, presence: true, numericality: true

  def self.editable_and_deletable(discount_name)
    @merchant_id = Discount.find_by(name: "#{discount_name}").merchant.id
    result = Discount.find_by_sql([
    "SELECT applied_discount
    FROM (
    SELECT 
        invoices.*,
        discounts.percentage_discount, 
        discounts.quantity_threshold, 
        discounts.name,
        discounts.merchant_id,
        invoice_items.quantity, 
        invoice_items.item_id, 
        items.unit_price,
        merchants.*,
        CASE 
            WHEN invoice_items.quantity >= discounts.quantity_threshold 
            AND invoices.status = 0
            AND merchants.id = #{@merchant_id}
            THEN
                discounts.name
            ELSE 
                NULL
        END AS applied_discount
    FROM 
        items
        INNER JOIN invoice_items ON items.id = invoice_items.item_id
        INNER JOIN merchants ON merchants.id = items.merchant_id
        INNER JOIN discounts ON discounts.merchant_id = merchants.id
        INNER JOIN invoices ON invoices.id = invoice_items.invoice_id
        )
    AS subquery
    WHERE applied_discount IS NOT NULL;"
  ])
    if result.pluck(:applied_discount).include?(discount_name)
      return false
    else
      return true
    end
  end
end