require 'rails_helper'

RSpec.describe 'merchant invoices index page (/merchants/:merchant_id/invoices)' do
  
  before :each do
    test_data_2
    @invoices = [@invoice1, @invoice2, @invoice3]
  end

  describe 'when I visit /merchants/:merchant_id/invoices' do
    it 'shows all the invoices that include at least on of my merchant items' do
      # 15. Merchant Invoice Show Page
      # As a merchant
      # When I visit my merchant's invoice show page (/merchants/:merchant_id/invoices/:invoice_id)
      # Then I see information related to that invoice including:
      # - Invoice id
      # - Invoice status
      # - Invoice created_at date in the format "Monday, July 18, 2019"
      # - Customer first and last name
      visit "/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}"
      expect(page).to have_content(@invoice1.id)
      expect(page).to have_content(@invoice1.status)
      expect(page).to have_content(@invoice1.created_at.strftime('%A, %B %d, %Y'))
      expect(page).to have_content(@invoice1.customer.name)
    end
    
    it "shows item and invoice_item information on the invoice" do
      # 16. Merchant Invoice Show Page: Invoice Item Information
      # As a merchant
      # When I visit my merchant invoice show page (/merchants/:merchant_id/invoices/:invoice_id)
      # Then I see all of my items on the invoice including:
      # - Item name
      # - The quantity of the item ordered
      # - The price the Item sold for
      # - The Invoice Item status
      # And I do not see any information related to Items for other merchants
      visit "/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}"
      expect(page).to have_content(@item1.name)
      expect(page).to have_content(@item2.name)
      expect(page).to have_content(@item3.name)
      expect(page).to have_content(@item4.name)
      expect(page).to have_content(@item6.name)
      expect(page).to have_content(@item7.name)
      expect(page).to have_content(@item8.name)

      expect(page).to have_content(@item1.unit_price)
      expect(page).to have_content(@item2.unit_price)
      expect(page).to have_content(@item3.unit_price)
      expect(page).to have_content(@item4.unit_price)
      expect(page).to have_content(@item6.unit_price)
      expect(page).to have_content(@item7.unit_price)
      expect(page).to have_content(@item8.unit_price)


      expect(page).to have_content(@invoice_item1.status)
      expect(page).to have_content(@invoice_item2.status)
      expect(page).to have_content(@invoice_item3.status)
      expect(page).to have_content(@invoice_item4.status)
      expect(page).to have_content(@invoice_item6.status)
      expect(page).to have_content(@invoice_item7.status)
      expect(page).to have_content(@invoice_item8.status)

      expect(page).to have_content(@invoice_item1.quantity)
      expect(page).to have_content(@invoice_item2.quantity)
      expect(page).to have_content(@invoice_item3.quantity)
      expect(page).to have_content(@invoice_item4.quantity)
      expect(page).to have_content(@invoice_item6.quantity)
      expect(page).to have_content(@invoice_item7.quantity)
      expect(page).to have_content(@invoice_item8.quantity)
    end

    it "shows total revenue" do
      # 17. Merchant Invoice Show Page: Total Revenue
      # As a merchant
      # When I visit my merchant invoice show page (/merchants/:merchant_id/invoices/:invoice_id)
      # Then I see the total revenue that will be generated from all of my items on the invoice
      visit "/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}"
      expect(page).to have_content("Total Revenue")
      expect(page).to have_content("$414.17")
    end

    it "has select field for each invoice_item status that can be updated" do
      # 18. Merchant Invoice Show Page: Update Item Status
      # As a merchant
      # When I visit my merchant invoice show page (/merchants/:merchant_id/invoices/:invoice_id)
      # I see that each invoice item status is a select field
      # And I see that the invoice item's current status is selected
      # When I click this select field,
      # Then I can select a new status for the Item,
      # And next to the select field I see a button to "Update Item Status"
      # When I click this button
      # I am taken back to the merchant invoice show page
      # And I see that my Item's status has now been updated
    @merchant1 = create(:merchant, name: "Target")
    @item1 = create(:item, name: "hat", description: "cool hat", unit_price: 10, merchant_id: @merchant1.id)
    @customer1 = create(:customer)
    @invoice1 = create(:invoice, status: 1, customer_id: @customer1.id)
    @invoice_item1 = InvoiceItem.create(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 4, unit_price: 10, status: 0)

      visit "/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}"
      expect(page).to have_selector("select")
      expect(find("select").value).to eq(@invoice_item1.status)
      select "packaged", from: "status_update"
      click_button "Update Item Status"
      expect(page).to have_current_path("/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}")
      @invoice_item1.reload
      expect(@invoice_item1.status).to eq("packaged")
      select "shipped", from: "status_update"
      click_button "Update Item Status"
      expect(page).to have_current_path("/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}")
      @invoice_item1.reload
      expect(@invoice_item1.status).to eq("shipped")
      select "pending", from: "status_update"
      click_button "Update Item Status"
      expect(page).to have_current_path("/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}")
      @invoice_item1.reload
      expect(@invoice_item1.status).to eq("pending")
    end
    it 'shows total revenue for merchant not including discount and a discounted revenue' do
      test_data_4
      # 6: Merchant Invoice Show Page: Total Revenue and Discounted Revenue
      # As a merchant
      # When I visit my merchant invoice show page
      # Then I see the total revenue for my merchant from this invoice (not including discounts)
      # And I see the total discounted revenue for my merchant from this invoice which includes bulk discounts in the calculation
      visit "/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}"
      #save_and_open_page
      expect(page).to have_content("Total Revenue")
      expect(page).to have_content("$414.17")
      expect(page).to have_content("Total Revenue After Applying Discounts")
      expect(page).to have_content("$307.93")
    end
    it 'has a link next to each invoice_item to the show page for the discount that was applied' do
      @discount1 = @merchant1.discounts.create(name: "Bulk Discount A", quantity_threshold: 10, percentage_discount: 10.00)
      @discount2 = @merchant1.discounts.create(name: "Bulk Discount B", quantity_threshold: 20, percentage_discount: 20.00)
      @discount3 = @merchant1.discounts.create(name: "Bulk Discount C", quantity_threshold: 50, percentage_discount: 50.00)
      # 7: Merchant Invoice Show Page: Link to applied discounts
      # As a merchant
      # When I visit my merchant invoice show page
      # Next to each invoice item I see a link to the show page for the bulk discount that was applied (if any)
      visit "/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}"
      expect(page).to have_link("Bulk Discount B")
      expect(page).to have_link("Bulk Discount C")
    end
  end
end