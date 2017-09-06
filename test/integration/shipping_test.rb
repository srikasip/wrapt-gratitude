require 'test_helper'

class ShippingTest < ActionDispatch::IntegrationTest
  def setup
    @shipment = Shipment.new

    @shipment.parcel = {
      :length        => 5,
      :width         => 1,
      :height        => 5.555,
      :distance_unit => :in,
      :weight        => 2,
      :mass_unit     => :lb
    }
  end

  if ENV['LIVE_NETWORK_TEST']
    def test_api_works
      _set_up_good_addresses
      @shipment.save!
      @shipment.reload
      assert(@shipment.api_response.present?)
      assert(@shipment.rates.present?)
      assert(@shipment.success?)
    end

    def test_label_failure
      _set_up_bad_addresses
      @shipment.run!
      @shipping_label = ShippingLabel.new
      @shipping_label.shippo_object_id = @shipment.rates.first['object_id']
      @shipping_label.save!
      @shipping_label.reload
      assert(@shipping_label.url.blank?)
      assert(@shipping_label.tracking_number.blank?)
      refute(@shipping_label.success?)
    end

    def test_label_success
      _set_up_good_addresses
      @shipment.run!
      @shipping_label = ShippingLabel.new
      @shipping_label.shippo_object_id = @shipment.rates.first['object_id']
      @shipping_label.save!
      @shipping_label.reload
      assert(@shipping_label.url.present?)
      assert(@shipping_label.tracking_number.present?)
      assert(@shipping_label.success?)
      puts @shipping_label.url
    end
  end

  private

  def _set_up_good_addresses
    @shipment.address_from = {
      :name    => 'Kristy Blackman',
      :street1 => '14325 Norwood',
      :city    => 'Leawood',
      :state   => 'KS',
      :zip     => '66224',
      :country => 'US',
      :phone   => '+1 555 341 9393',
      :email   => 'whocares@example.com'
    }

    @shipment.address_to = {
      :name    => 'Todd Blackman',
      :street1 => '319 Hague Rd.',
      :city    => 'Dummerston',
      :state   => 'VT',
      :zip     => '05301',
      :country => 'US',
      :phone   => '+1 555 341 9393',
      :email   => 'somebodyelse@example.com'
    }
  end

  def _set_up_bad_addresses
    @shipment.address_from = {
      :name    => 'Shawn Ippotle',
      :street1 => '965 Mission St.',
      :city    => 'San Francisco',
      :state   => 'CA',
      :zip     => '94117',
      :country => 'US',
      :phone   => '+1 555 341 9393',
      :email   => 'shippotle@goshippo.com'
    }

    @shipment.address_to = {
      :name    => 'Mr Hippo',
      :street1 => 'Broadway 1',
      :city    => 'New York',
      :state   => 'NY',
      :zip     => '10007',
      :country => 'US',
      :phone   => '+1 555 341 9393',
      :email   => 'mrhippo@goshippo.com'
    }
  end
end
