require "rails_helper"

RSpec.describe Discount, type: :model do
  before :each do
    test_data_2
  end
  
  describe "relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:item_discounts) }
    it { should have_many(:items).through(:item_discounts) }
  end

  describe "validations" do
    it { should validate_presence_of(:percentage_discount) }
    it { should validate_presence_of(:quantity_threshold) }
    it { should validate_presence_of(:merchant_id) }
    it { should validate_numericality_of(:merchant_id) }

  end
end