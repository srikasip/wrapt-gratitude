require 'rails_helper'

describe Shipment do
  let(:shipment) do
    Shipment.new({
      address_to: {
        street1: '319 Hague Rd',
        city: 'Dummerston',
        zip: '05301',
        state: 'VT',
        country: 'US',
        phone:  '123-123-1234',
        email: 'example@example.com',
      },
      address_from: {
        street1: '14321 Norwood',
        city: 'Leawood',
        zip: '66212',
        state: 'KS',
        country: 'US',
        phone:  '123-123-1234',
        email: 'example@example.com',
      },
      parcel: {
        length: 5,
        width: 1,
        height: 5.555,
        distance_unit: :in,
        weight:  2,
        mass_unit: :lb
      }
    })
  end

  it "should have a baseline" do
    expect(Shipment.new.success?).to be_falsey
  end

  it "should work without insurance" do
    VCR.use_cassette('without insurance') do
      shipment.run!
      expect(shipment.success?).to be_truthy
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
