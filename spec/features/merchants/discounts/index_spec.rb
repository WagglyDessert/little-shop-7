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
      # 2: Merchant Bulk Discount Create
      # As a merchant
      # When I visit my bulk discounts index
      # Then I see a link to create a new discount
      # When I click this link
      # Then I am taken to a new page where I see a form to add a new bulk discount
      # When I fill in the form with valid data
      # Then I am redirected back to the bulk discount index
      # And I see my new bulk discount listed
      visit "/merchants/#{@merchant1.id}/discounts"
      expect(page).to have_link("Create New Discount")
      click_link("Create New Discount")
      expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts/new")

      fill_in 'Name', with: 'Bulk Discount C'
      fill_in 'Quantity threshold', with: 30
      fill_in 'Percentage discount', with: 30.00
      click_button("Submit Form")
      expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts")
      expect(page).to have_content("Bulk Discount C")
      expect(page).to have_content("Percentage Discount: 30.0%")
      expect(page).to have_content("Quantity Threshold: 30 Items")
    end
    it "has button to delete a discount" do
      # 3: Merchant Bulk Discount Delete
      # As a merchant
      # When I visit my bulk discounts index
      # Then next to each bulk discount I see a button to delete it
      # When I click this button
      # Then I am redirected back to the bulk discounts index page
      # And I no longer see the discount listed
      visit "/merchants/#{@merchant1.id}/discounts"
      expect(page).to have_button("Delete #{@discount1.name}")
      click_button("Delete #{@discount1.name}")
      expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts")
      expect(page).to have_content("Bulk Discount B")
      expect(page).to_not have_content("Bulk Discount A")
    end
  end
end