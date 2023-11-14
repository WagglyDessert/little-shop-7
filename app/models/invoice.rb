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
  
  def self.total_revenue_after_discount(invoice_id)
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
        invoice_items.invoice_id = #{invoice_id}
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
                  THEN invoice_items.quantity * items.unit_price * 0.01
                  ELSE 0
              END
          ) AS min_discount
      FROM 
          items
          INNER JOIN invoice_items ON items.id = invoice_items.item_id
          INNER JOIN merchants ON merchants.id = items.merchant_id
          INNER JOIN discounts ON discounts.merchant_id = merchants.id
      WHERE 
          invoice_items.invoice_id = #{invoice_id}
      GROUP BY 
          invoice_items.item_id
  ) AS min_discounts_summary;"
])
  #require 'pry'; binding.pry
    total += no_discount_result.pluck(:total_min_discount).first
    total
  end


  # def total_revenue_after_discount
  #   @merchant_array = []
  #   @discounts = []
  #   items.each do |i|
  #     @merchant_array << i.merchant
  #   end
  #   @merchant_array.uniq.each do |m|
  #     if m.discounts.present?
  #       @discounts << m.discounts
  #     end
  #   end
  #   require 'pry'; binding.pry
  #   if @discounts != nil
  #     items_with_discounts = Discount
  #         .joins(merchant: { items: :invoice_items })
  #         .where('invoice_items.invoice_id' => self.id)
  #         .where('invoice_items.quantity >= quantity_threshold')
  #         .order('discounts.id DESC')
  #         .select('discounts.*, invoice_items.*')
  #         .sum("invoice_items.unit_price * quantity * 0.01 * ((100.00 - percentage_discount)/100)")

  #       items_without_discounts = Discount
  #         .joins(merchant: { items: :invoice_items })
  #         .where('invoice_items.invoice_id' => self.id)
  #         .where('discounts.quantity_threshold = (SELECT MIN(quantity_threshold) FROM discounts)')
  #         .where('invoice_items.quantity < quantity_threshold')
  #         .select('discounts.*, invoice_items.quantity, invoice_items.unit_price')
  #         .sum("invoice_items.unit_price * quantity * 0.01")
          
  #       total = 0.00
  #       total += items_without_discounts
  #       total += items_with_discounts
  #   else
  #     self.invoice_items.each do |ii|
  #       total = (ii.unit_price * ii.quantity * 0.01)
  #       total.round(2)
  #     end
  #   end
  # end

  #IM LEAVING THIS METHOD TO SHOW ALTERNATE SOLUTION
  def total_revenue_after_discount_2
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

