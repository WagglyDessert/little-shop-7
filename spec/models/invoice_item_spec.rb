require "rails_helper"

RSpec.describe InvoiceItem, type: :model do
  before :each do
    test_data 
  end

  describe "relationships" do
    it { should belong_to(:invoice) }
    it { should belong_to(:item) }
  end

  describe "validations" do
    it { should validate_presence_of(:invoice_id) }
    it { should validate_numericality_of(:invoice_id) }
    it { should validate_presence_of(:item_id) }
    it { should validate_numericality_of(:item_id) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_numericality_of(:unit_price) }
    it { should validate_presence_of(:status) }
    it { should define_enum_for(:status).with_values(pending: 0, packaged: 1, shipped: 2) }
  end

  describe '#price' do
    it 'returns the invoice item unit price with a decimal' do
      testing_invoice = create(:invoice_item, unit_price: 2599)
      expect(testing_invoice.price).to eq(25.99)
    end
  end

  describe '#applied_discount' do
    it 'shows applied discount for an invoice_item' do
      test_data_2
      @invoice_item17 = InvoiceItem.create(item_id: @item8.id, invoice_id: @invoice3.id, quantity: 10, unit_price: 3, status: 2)
      @invoice_item18 = InvoiceItem.create(item_id: @item7.id, invoice_id: @invoice3.id, quantity: 22, unit_price: 5, status: 2)

      @discount1 = @merchant1.discounts.create(name: "Bulk Discount A", quantity_threshold: 10, percentage_discount: 10.00)
      @discount2 = @merchant1.discounts.create(name: "Bulk Discount B", quantity_threshold: 20, percentage_discount: 20.00)
      @discount3 = @merchant1.discounts.create(name: "Bulk Discount C", quantity_threshold: 50, percentage_discount: 50.00)

      expected_discount_for_invoice_item_1 = nil
      expected_discount_for_invoice_item_2 = @discount3
      expected_discount_for_invoice_item_17 = @discount1
      expected_discount_for_invoice_item_18 = @discount2

      expect(@invoice_item1.discount_applied).to eq(expected_discount_for_invoice_item_1)
      expect(@invoice_item2.discount_applied).to eq(expected_discount_for_invoice_item_2)
      expect(@invoice_item17.discount_applied).to eq(expected_discount_for_invoice_item_17)
      expect(@invoice_item18.discount_applied).to eq(expected_discount_for_invoice_item_18)
    end
  end
end