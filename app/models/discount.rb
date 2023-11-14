class Discount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant

  validates :percentage_discount, presence: true
  validates :quantity_threshold, presence: true
  validates :name, presence: true
  validates :merchant_id, presence: true, numericality: true

end