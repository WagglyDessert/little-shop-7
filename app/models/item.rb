class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :discounts, through: :merchant

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: true
  validates :merchant_id, presence: true, numericality: true

  def top_sale_date
    invoice_items.order(quantity: :desc).first.invoice.format_date
  end
  
end