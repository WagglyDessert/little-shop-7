FactoryBot.define do
  factory :item_discount do
    association :item, factory: :item
    association :discount, factory: :discount
  end
end