require "rails_helper"

RSpec.describe ItemDiscount, type: :model do
  before :each do
    test_data_2
  end
  
  describe "relationships" do
    it { should belong_to(:item) }
    it { should belong_to(:discount) }
  end

  describe "validations" do
    it { should validate_presence_of(:item_id) }
    it { should validate_numericality_of(:item_id) }
    it { should validate_presence_of(:discount_id) }
    it { should validate_numericality_of(:discount_id) }
  end
end