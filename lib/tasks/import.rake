namespace :import do
  desc "TODO"
  task customers: :environment do
    require "csv"

    csv_text = File.read(Rails.root.join("db", "data", "customers.csv"))
    csv = CSV.parse(csv_text, :headers => true, :encoding => "ISO-8859-1")
    csv.each do |row|
      t = Customer.new
      t.id = row["id"]
      t.first_name = row["first_name"]
      t.last_name = row["last_name"]
      t.created_at = row["created_at"]
      t.updated_at = row["updated_at"]
      t.save
    end
  end
  puts "Seeded bro"
end
