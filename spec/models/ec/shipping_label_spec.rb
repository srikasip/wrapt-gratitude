require "rails_helper"

describe Ec::ShippingLabel do
  include ShippoShipments

  it "should be purchaseable" do
    VCR.use_cassette('buying shipping') do
      shipment.run!
      chosen_rate_id = shipment.rates.first['object_id']
      label = Ec::ShippingLabel.new(shippo_object_id: chosen_rate_id, shipment: shipment)
      # Might need a delay here when first recording cassette
      # sleep 5
      label.run!
      expect(label.success?).to be_truthy
    end
  end
end
