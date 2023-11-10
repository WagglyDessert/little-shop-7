class AddNameToDiscounts < ActiveRecord::Migration[7.0]
  def change
    add_column :discounts, :name, :string
  end
end
