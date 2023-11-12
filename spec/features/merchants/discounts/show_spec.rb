require "rails_helper"

RSpec.describe "MerchantDiscounts" do
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
  describe "discount show page" do
    it "has information about the discount such as name, quantity threshold, and percentage discount" do
      # 4: Merchant Bulk Discount Show
      # As a merchant
      # When I visit my bulk discount show page
      # Then I see the bulk discount's quantity threshold and percentage discount
      visit "/merchants/#{@merchant1.id}/discounts/#{@discount1.id}"
      expect(page).to have_content("Discount Name: #{@discount1.name}")
      expect(page).to have_content("Percentage Discount: #{@discount1.percentage_discount}%")
      expect(page).to have_content("Quantity Threshold: #{@discount1.quantity_threshold} Items")
    end
    it "has link to edit discount" do
      # 5: Merchant Bulk Discount Edit
      # As a merchant
      # When I visit my bulk discount show page
      # Then I see a link to edit the bulk discount
      # When I click this link
      # Then I am taken to a new page with a form to edit the discount
      # And I see that the discounts current attributes are pre-populated in the form
      # When I change any/all of the information and click submit
      # Then I am redirected to the bulk discount's show page
      # And I see that the discount's attributes have been updated
      visit "/merchants/#{@merchant1.id}/discounts/#{@discount1.id}"
      expect(page).to have_link("Edit #{@discount1.name}")
      click_link("Edit #{@discount1.name}")

      expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts/#{@discount1.id}/edit")
      expect(page).to have_field('Name', with: @discount1.name)
      expect(page).to have_field('Quantity threshold', with: @discount1.quantity_threshold)
      expect(page).to have_field('Percentage discount', with: @discount1.percentage_discount)
      fill_in 'Name', with: 'Bulk Discount NATHAN'
      fill_in 'Quantity threshold', with: 50
      fill_in 'Percentage discount', with: 50.00
      click_button("Update #{@discount1.name}")

      expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts/#{@discount1.id}")
      expect(page).to have_content("Discount Name: Bulk Discount NATHAN")
      expect(page).to have_content("Percentage Discount: 50.0%")
      expect(page).to have_content("Quantity Threshold: 50 Items")
      expect(page).to_not have_content("Discount Name: #{@discount1.name}")
      expect(page).to_not have_content("Percentage Discount: #{@discount1.quantity_threshold} Items")
      expect(page).to_not have_content("Quantity Threshold: #{@discount1.percentage_discount}%")
    end
  end
end