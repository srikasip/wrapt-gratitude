require 'rails_helper'

describe Shipment do
  include ShippoShipments

  it "should have a baseline" do
    expect(Shipment.new.success?).to be_falsey
  end

  it "should work without insurance" do
    VCR.use_cassette('without insurance') do
      shipment.run!
      expect(shipment.success?).to be_truthy
    end
  end

  it "should provide some rates" do
    VCR.use_cassette('without insurance') do
      shipment.run!
      expect(shipment.rates.length).to be >= 3
      puts shipment.api_response['messages'].ai
    end
  end

  it "should work with insurance" do
    VCR.use_cassette('with insurance') do
      shipment.insurance_in_dollars = 50
      shipment.description_of_what_to_insure = 'necklace'
      shipment.run!
      expect(shipment.success?).to be_truthy
      insurance = shipment.api_response.dig('extra', 'insurance', 'amount').to_i
      expect(insurance).to eq 50
    end
  end
end
