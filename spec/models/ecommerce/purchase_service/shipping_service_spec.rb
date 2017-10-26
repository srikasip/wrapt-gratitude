require "rails_helper"

describe PurchaseService::ShippingService do
  let(:path)           { File.join(Rails.root, 'spec', 'fixtures', 'shippo.payload.rb') }
  let(:payload)        { eval(File.read(path)) }
  let(:customer_order) { FactoryGirl.create :customer_order, :with_shipping_label }

  it "should process shippo payload" do
    customer_order
    ShippingLabel.update_all(tracking_number: '92055901755477000032739723')

    PurchaseService::ShippingService.update_shipping_status!(payload.dig('data'), do_gift_count_update: false)

    shipping_label = ShippingLabel.first

    expect(shipping_label.shipped_on.to_s).to eq('2017-10-26')
    expect(shipping_label.delivered_on).to be_nil
  end
end
