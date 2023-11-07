class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices, through: :items

  validates :name, presence: true
  
  def popular_items
    self.items.select('items.id, items.name, invoice_items.unit_price, (SUM(invoice_items.quantity) * invoice_items.unit_price) as total_revenue')
    .joins(invoices: :transactions)
    .where(transactions: { result: 1 })
    .group('items.id, items.name, invoice_items.unit_price')
    .order('total_revenue DESC')
    .limit(5)
  end

  def self.popular_merchants
    self.joins(items: :invoice_items)
    .select('merchants.id, merchants.name, (SUM(invoice_items.quantity * invoice_items.unit_price) /100 )as total_revenue')
    .group('merchants.id, merchants.name')
    .order('total_revenue DESC')
    .limit(5)
  end
end