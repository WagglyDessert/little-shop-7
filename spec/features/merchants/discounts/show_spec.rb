require "rails_helper"

RSpec.describe "Dashboard" do
  before :each do
    test_data 
    @customer0 = Customer.create(first_name: "Angus", last_name: "Turing")
      @invoice0 = @customer0.invoices.create(status: 1)

      @item2 = @merchant1.items.create(name: "Bat", description: "Bat", unit_price: 200)
      @item3 = @merchant1.items.create(name: "Cat", description: "Cat", unit_price: 300)
      @item4 = @merchant1.items.create(name: "Rat", description: "Rat", unit_price: 400)

      @transaction0 = @invoice0.transactions.create(credit_card_number: 1234, credit_card_expiration_date: 01/11, result: 1)

      @ii1 = create(:invoice_item, item: @item2, invoice: @invoice0, status: 0)
      @ii2 = create(:invoice_item, item: @item3, invoice: @invoice0, status: 1)
      @ii3 = create(:invoice_item, item: @item4, invoice: @invoice0, status: 2)

      @discount1 = @merchant1.discounts.create(name: "Bulk Discount A", quantity_threshold: 10, percentage_discount: 10.00)
      @discount2 = @merchant1.discounts.create(name: "Bulk Discount B", quantity_threshold: 20, percentage_discount: 20.00)
  end
  describe "discounts index" do
    it "has links to make a new discount" do
      # 4: Merchant Bulk Discount Show
      # As a merchant
      # When I visit my bulk discount show page
      # Then I see the bulk discount's quantity threshold and percentage discount
      visit "/merchants/#{@merchant1.id}/discounts/#{@discount1.id}"
      expect(page).to have_content(@discount1.name)
      expect(page).to have_content(@discount1.quantity_threshold)
      expect(page).to have_content(@discount1.percentage_discount)
    end
  end
end