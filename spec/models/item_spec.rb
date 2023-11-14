require "rails_helper"

RSpec.describe Item, type: :model do
  before :each do
    test_data_2
  end
  
  describe "relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:discounts).through(:merchant) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:merchant_id) }
    it { should validate_numericality_of(:merchant_id) }
  end

  describe 'top_sale_date' do
    it 'provides top sale date' do
      expect(@item3.top_sale_date).to eq("Sunday, January  1, 2023")
    end
  end
end