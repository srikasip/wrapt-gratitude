require 'test_helper'

class ShipmentTest < ActiveSupport::TestCase
  def shipment
    @shipment ||= Shipment.new({
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

  def test_baseline
    refute Shipment.new.success?
  end

  def test_without_insurance
    shipment.run!
    assert shipment.success?
  end

  def test_with_insurance
    shipment.insurance_in_dollars = 50
    shipment.description_of_what_to_insure = 'necklace'
    shipment.run!
    assert shipment.success?
    insurance = shipment.api_response.dig('extra', 'insurance', 'amount').to_i
    assert_equal 50, insurance
  end
end
