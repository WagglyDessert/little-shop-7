FactoryBot.define do
  factory :discount do
    name { Faker::Commerce.product_name }
    quantity_threshold { Faker::Number.between(from: 1000, to: 10000) }
    percentage_discount { Faker::Number.decimal(l_digits: 2) }
    association :merchant, factory: :merchant
  end
end