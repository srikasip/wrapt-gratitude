class BlacklistSomeServiceLevels < ActiveRecord::Migration[5.0]
  def change
    begin
      blacklist_names = [
        ['USPS', 'Priority Mail Express International'],
        ['USPS', 'First Class Package International'],
        ['UPS', 'Second Day Air®'],
        ['UPS', 'Second Day Air A.M.®'],
        ['UPS', 'Next Day Air®'],
        ['UPS', 'Next Day Air Saver®'],
        ['UPS', 'Mail Innovations (domestic)'],
        ['UPS', 'Express®'],
        ['UPS', 'Express Plus®'],
        ['UPS', 'Expedited®'],
        ['USPS', 'Parcel Select'],
        ['FedEx', 'Express Saver'],
        ['FedEx', '2 Day'],
        ['FedEx', '2 Day A.M.'],
        ['FedEx', 'Standard Overnight'],
        ['FedEx', 'First Overnight'],
        ['FedEx', 'Priority Overnight']
      ]

      blacklist_names.each do |data|
        carrier_name, level_name= data
        carrier = ShippingCarrier.find_by!(name: carrier_name)

        ssl = ShippingServiceLevel.find_by!(name: level_name, shipping_carrier: carrier)
        ssl.active = false
        ssl.save!
      end

    rescue Exception => e
      puts "Data migration failed in #{__FILE__}: #{e.message}"
    end
  end
end
