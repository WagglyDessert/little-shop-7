class Discount < ApplicationRecord
  belongs_to :merchant
  has_many :item_discounts
  has_many :items, through: :item_discounts

  validates :percentage_discount, presence: true
  validates :quantity_threshold, presence: true

end