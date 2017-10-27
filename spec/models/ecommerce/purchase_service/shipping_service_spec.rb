require "rails_helper"

describe PurchaseService::ShippingService do
  let(:path)           { File.join(Rails.root, 'spec', 'fixtures', 'shippo.payload.rb') }
  let(:payload)        { eval(File.read(path)) }
  let(:customer_order) { FactoryGirl.create :customer_order, :with_shipping_label }
  let(:mailer_double)  { double('Customer Order Mail').as_null_object }

  before(:each) do
    customer_order
    ShippingLabel.update_all(tracking_number: '92055901755477000032739723')
  end

  it "should process shippo payload" do
    allow(CustomerOrderMailer).to receive('order_shipped').and_return(mailer_double)
    PurchaseService::ShippingService.update_shipping_status!(payload.dig('data'), do_gift_count_update: false)

    shipping_label = ShippingLabel.first

    expect(shipping_label.shipped_on.to_s).to eq('2017-10-26')
    expect(shipping_label.delivered_on).to be_nil
  end

  it "should only email about shipping once" do
    expect(CustomerOrderMailer).to receive('order_shipped').and_return(mailer_double).once

    PurchaseService::ShippingService.update_shipping_status!(payload.dig('data'), do_gift_count_update: false)
    PurchaseService::ShippingService.update_shipping_status!(payload.dig('data'), do_gift_count_update: false)
  end
end
