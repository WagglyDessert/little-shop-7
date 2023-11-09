class InvoiceItem < ApplicationRecord
  belongs_to :discount
  belongs_to :item
 
  validates :discount_id, presence: true, numericality: true
  validates :item_id, presence: true, numericality: true

end