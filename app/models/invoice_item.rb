class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  enum status: {"pending": 0, "packaged": 1, "shipped": 2}
 
  validates :invoice_id, presence: true, numericality: true
  validates :item_id, presence: true, numericality: true
  validates :quantity, presence: true, numericality: true
  validates :unit_price, presence: true, numericality: true
  validates :status, presence: true
  
  def price
    (unit_price * 0.01).round(2)
  end

  def discount_applied
    discounts = self.item.merchant.discounts.sort_by(&:percentage_discount)
    if self.item.merchant.discounts.present?
      discounts.each do |d|
        if self.quantity >= d.quantity_threshold
          @discount_applied = d
        end
      end
      @discount_applied
    end
  end
end