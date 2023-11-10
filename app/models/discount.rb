class Discount < ApplicationRecord
  belongs_to :merchant
  has_many :item_discounts
  has_many :items, through: :item_discounts

  validates :percentage_discount, presence: true
  validates :quantity_threshold, presence: true
  validates :name, presence: true
  validates :merchant_id, presence: true, numericality: true

end