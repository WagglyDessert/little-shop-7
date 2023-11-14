require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe "relationships" do
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
    it { should belong_to(:customer) }
  end
  
  describe "validations" do
      it { should validate_presence_of(:customer_id) }
      it { should validate_presence_of(:status) }
  end
  
  describe '#self.incomplete_not_shipped' do
    it 'will return invoices that are incomplete if any invoice items are packaged' do
      test_data
      packaged_invoice = @incomplete
      expect(Invoice.incomplete_not_shipped.include?(packaged_invoice)).to eq(true)
    end
    
    it 'will return invoices that are incomplete if any invoice items are pending' do
      test_data
      packaged_invoice = @incomplete2
      expect(Invoice.incomplete_not_shipped.include?(packaged_invoice)).to eq(true)
    end
  end

  describe "#format_date" do
    it "should return a new format for date created" do 
      test_invoice = create(:invoice, created_at: Time.new(2021, 3, 9))
      expect(test_invoice.format_date).to eq("Tuesday, March  9, 2021")
    end
  end 

  describe "#potential_revenue" do
    it "should return the total potential revenue of that invoice" do 
      test_data
      @test_invoice = @customer1.invoices.first
      @test_invoice.update(status: 0, created_at: Time.new(2021, 12, 30))
      create(:invoice_item, item_id: @item1.id, unit_price: 1500, quantity: 5, invoice_id: @test_invoice.id, status: 2)
      create(:invoice_item, item_id: @item2.id, unit_price: 1850, quantity: 8, invoice_id: @test_invoice.id, status: 2)
      create(:invoice_item, item_id: @item3.id, unit_price: 2500, quantity: 6, invoice_id: @test_invoice.id, status: 1)
      create(:invoice_item, item_id: @item4.id, unit_price: 1200, quantity: 10, invoice_id: @test_invoice.id, status: 2)
      
      expected_total = 0
      @test_invoice.invoice_items.each do |ii|
        expected_total+=(ii.unit_price * ii.quantity)
      end
      expected_total = (0.01 * expected_total).round(2)
      expect(@test_invoice.potential_revenue).to eq(expected_total)
    end
  end 

  describe "#self.sort_alphabetical" do
    it "should sort the invoice data alphabetically" do
      test_data
      alphabetical = Invoice.all.sort
      expect(Invoice.sort_alphabetical).to eq(alphabetical)
    end
  end 

  describe "#self.sort_by_date" do
    it "should sort the invoice data alphabetically" do
      invoice1 = create(:invoice, created_at: Time.new(2022, 3, 9))
      invoice2 = create(:invoice, created_at: Time.new(2021, 3, 9))
      invoice3 = create(:invoice, created_at: Time.new(2020, 3, 9))
      order = [invoice1, invoice2, invoice3]
      expect(Invoice.sort_by_date).to eq(order)
    end
  end 

  describe "#potential_revenue_after_discounts" do
    it "should return the total potential revenue of that invoice after discounts are applied" do 
      test_data_2
      @test_invoice = @customer2.invoices.first
      @test_invoice.update(status: 0, created_at: Time.new(2021, 12, 30))
      
      @discount1 = @merchant1.discounts.create(name: "Bulk Discount A", quantity_threshold: 10, percentage_discount: 10.00)
      @discount2 = @merchant1.discounts.create(name: "Bulk Discount B", quantity_threshold: 20, percentage_discount: 20.00)
      @discount3 = @merchant1.discounts.create(name: "Bulk Discount C", quantity_threshold: 50, percentage_discount: 50.00)
      
      #this tests that different discounts are applied to different items
      expected_total = ((@invoice_item9.unit_price * @invoice_item9.quantity * 0.01) + (@invoice_item10.unit_price * @invoice_item10.quantity * 0.01 * ((100.0 - @discount2.percentage_discount) / 100)) + (@invoice_item11.unit_price * @invoice_item11.quantity * 0.01) + (@invoice_item12.unit_price * @invoice_item12.quantity * 0.01) + (@invoice_item13.unit_price * @invoice_item13.quantity * 0.01) + (@invoice_item15.unit_price * @invoice_item15.quantity * 0.01 * ((100.0 - @discount3.percentage_discount) / 100)))
      expect(Invoice.total_revenue_after_discount(@test_invoice.id).to_i).to eq(expected_total.to_i)
    end
    it "tests that total_revenue_after_discounts works when there are no discounts" do 
      test_data_2
      @test_invoice = @customer2.invoices.first
      @test_invoice.update(status: 0, created_at: Time.new(2021, 12, 30))
      
      #this tests no discounts 
      expected_total = ((@invoice_item9.unit_price * @invoice_item9.quantity * 0.01) + (@invoice_item10.unit_price * @invoice_item10.quantity * 0.01) + (@invoice_item11.unit_price * @invoice_item11.quantity * 0.01) + (@invoice_item12.unit_price * @invoice_item12.quantity * 0.01) + (@invoice_item13.unit_price * @invoice_item13.quantity * 0.01) + (@invoice_item15.unit_price * @invoice_item15.quantity * 0.01)).round(2)
      expect(Invoice.total_revenue_after_discount(@test_invoice.id).to_i).to eq(expected_total.to_i)
    end
    it "tests that the total_revenue_after_discounts does not discount purchased items that belong to another merchant who does not have a discount" do 
      test_data_2
      @test_invoice = @customer2.invoices.first
      @test_invoice.update(status: 0, created_at: Time.new(2021, 12, 30))
      
      @merchant2 = create(:merchant, name: "Discountless")
      @item8 = create(:item, name: "crystal shard", description: "beautiful", unit_price: 1000, merchant_id: @merchant2.id)
      @invoice_item17 = InvoiceItem.create(item_id: @item8.id, invoice_id: @invoice2.id, quantity: 100, unit_price: 1000, status: 1)

      @discount1 = @merchant1.discounts.create(name: "Bulk Discount A", quantity_threshold: 10, percentage_discount: 10.00)
      @discount2 = @merchant1.discounts.create(name: "Bulk Discount B", quantity_threshold: 20, percentage_discount: 20.00)
      @discount3 = @merchant1.discounts.create(name: "Bulk Discount C", quantity_threshold: 50, percentage_discount: 50.00)
      
      #this tests that buying an item that belongs to a merchant without discounts will not apply a discount to the item when other items are bought from a merchant that gives discounts
      expected_total = ((@invoice_item9.unit_price * @invoice_item9.quantity * 0.01) + (@invoice_item10.unit_price * @invoice_item10.quantity * 0.01 * ((100.0 - @discount2.percentage_discount) / 100)) + (@invoice_item11.unit_price * @invoice_item11.quantity * 0.01) + (@invoice_item12.unit_price * @invoice_item12.quantity * 0.01) + (@invoice_item13.unit_price * @invoice_item13.quantity * 0.01) + (@invoice_item15.unit_price * @invoice_item15.quantity * 0.01 * ((100.0 - @discount3.percentage_discount) / 100)) + (@invoice_item17.unit_price * @invoice_item17.quantity * 0.01))
      expect(Invoice.total_revenue_after_discount(@test_invoice.id).to_i).to eq(expected_total.to_i)
    end
  end 
end