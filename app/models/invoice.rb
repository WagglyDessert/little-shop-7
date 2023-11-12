class Invoice < ApplicationRecord
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :transactions
  belongs_to :customer

  validates :customer_id, presence: true, numericality: true
  validates :status, presence: true

  enum status: {"in progress": 0, "completed": 1, "cancelled": 2}

  def self.incomplete_not_shipped
    Invoice.joins(items: :invoice_items)
           .where(invoice_items: {status: ["pending", "packaged"]})
           .distinct
           .order(created_at: :asc)
  end

  def format_date
    created_at.strftime('%A, %B %e, %Y')
  end

  def potential_revenue
    invoice_items.sum("unit_price * quantity * .01").round(2)
  end

  def self.sort_alphabetical
    Invoice.all.order(id: :asc)
  end

  def self.sort_by_date
    Invoice.all.order(created_at: :desc)
  end
  
  def total_revenue_after_discount
    total = 0.00
    invoice_items.each do |ii|
      #reset number_d and number
      @number_d = 0
      @number = 0
      @merchant = ii.item.merchant
      if @merchant.discounts.present?
        # sort discounts from lowest discount to highest
        # @merchant.discounts.sort_by(percentage_discount)
        @discounts = @merchant.discounts.sort_by(&:percentage_discount)
        # discounts.each do
        @discounts.each do |discount|
          # if (invoice_item.quantity) > discount.quantity_threshold
          if ii.quantity >= discount.quantity_threshold
          # number = invoice_items.sum("unit_price * quantity * #{discount.percentage_discount}").round(2)
            @number_d = (ii.unit_price * ii.quantity * 0.01 * ((100.0 - discount.percentage_discount) / 100))
          else
            @number = (ii.unit_price * ii.quantity * 0.01)
          end
        end
        if @number_d != 0
          total += @number_d
        else
          total += @number
        end
      # if merchant doesn't have any discounts, call on potential_revenue method
      else
        @number = (ii.unit_price * ii.quantity * 0.01)
        total += @number
      end
    end
    total.round(2)   
  end
end