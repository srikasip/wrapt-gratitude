require "rails_helper"

describe PurchaseService::ShippingService do
  let(:path)           { File.join(Rails.root, 'spec', 'fixtures', 'shippo.payload.rb') }
  let(:payload)        { eval(File.read(path)) }
  let(:customer_order) { FactoryGirl.create :customer_order, :with_shipping_label }

  it "should process shippo payload" do
    customer_order
    ShippingLabel.update_all(tracking_number: '92055901755477000032739723')

    PurchaseService::ShippingService.update_shipping_status!(payload.dig('data'), do_gift_count_update: false)
  end
end
