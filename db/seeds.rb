# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Transaction.destroy_all
Invoice.destroy_all
InvoiceItem.destroy_all
Item.destroy_all
Merchant.destroy_all
Customer.destroy_all

Rake::Task["csv_load:all"].invoke

@discount1 = Discount.create(name: "Bulk Discount A", quantity_threshold: 10, percentage_discount: 10.00, merchant_id: 9)
@discount2 = Discount.create(name: "Bulk Discount B", quantity_threshold: 20, percentage_discount: 20.00, merchant_id: 9)
@discount3 = Discount.create(name: "Bulk Discount C", quantity_threshold: 50, percentage_discount: 50.00, merchant_id: 9)