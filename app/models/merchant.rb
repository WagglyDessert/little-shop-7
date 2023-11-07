class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices, through: :items
  has_many :customers, through: :invoices
  has_many :invoice_items, through: :items

  validates :name, presence: true
  
  def top_5_customers_from_transactions
    customers.joins(invoices: :transactions)
    .where(transactions: {result: "success"})
    .select("customers.*, COUNT(DISTINCT transactions.*) AS num_transactions")
    .group(:id)
    .order(num_transactions: :desc)
    .limit(5)
  end

  def popular_items
    self.items.select('items.id, items.name, invoice_items.unit_price, (SUM(invoice_items.quantity) * invoice_items.unit_price * 0.01) as total_revenue')
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

  def best_day
      self.invoice_items.select("invoice.id, sum(invoice_items.quantity * invoice_items.unit_price) as revenue").group(:id).order('revenue desc').first

      # revenues = Hash.new(0)

    # invoices.each do |invoice|
    #   total_revenue = invoice.invoice_items.sum { |item| item.quantity * item.unit_price }
    #   revenues[invoice.created_at.to_date] += total_revenue
    # end
    # top_day = revenues.max_by { |day, revenue| revenue }&.first

    # top_day
  end
    
  def items_ready_to_ship_ordered_oldest_to_newest
    self.items
    .joins(:invoices)
    .select("invoice_items.*", "items.name", "invoices.created_at AS date")
    .where("invoice_items.status = ? OR invoice_items.status = ?", "0", "1")
    .group('invoice_items.id', 'items.name', 'invoices.created_at')
    .order("invoices.created_at asc")
  end

  def self.sort_alphabetical
    Merchant.all.order(name: :asc)
  end

  def self.sort_by_date
    Merchant.all.order(created_at: :desc)
  end
end
