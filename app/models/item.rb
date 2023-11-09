class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :item_discounts
  has_many :discounts, through: :item_discounts

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: true
  validates :merchant_id, presence: true, numericality: true

  def top_sale_date
    invoice_items.order(quantity: :desc).first.invoice.format_date
  end

  def applicable_bulk_discount
    eligible_discounts = merchant.bulk_discounts
                         .joins(:item_bulk_discounts)
                         .where(item_bulk_discounts: { item_id: id })
                         .where('quantity_threshold <= ?', quantity_ordered)
                         .order(percentage_discount: :desc)

    eligible_discounts.first
  end
end