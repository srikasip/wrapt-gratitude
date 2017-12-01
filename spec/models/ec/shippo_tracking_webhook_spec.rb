require "rails_helper"

describe Ec::ShippoTrackingWebhook do
  let(:params) do
    {
      "test"=>true,
      "data"=> {
        "messages"=>[],
        "carrier"=>"usps",
        "tracking_number"=>"123",
        "address_from"=>{"city"=>"Las Vegas", "state"=>"NV", "zip"=>"89101", "country"=>"US"},
        "address_to"=>{"city"=>"Spotsylvania", "state"=>"VA", "zip"=>"22551", "country"=>"US"},
        "eta"=>"2017-09-30T17:51:23.639",
        "original_eta"=>"2017-09-30T17:51:23.639",
        "servicelevel"=>{"token"=>"usps_priority", "name"=>"Priority Mail"},
        "metadata"=>"Shippo test webhook",
        "tracking_status"=>{
          "status"=>"UNKNOWN",
          "object_created"=>"2017-09-25T17:51:23.648",
          "status_date"=>"2017-09-25T17:51:23.648",
          "object_id"=>"8023f999c99149d08212a6dc1f15f1f4",
          "location"=>{"city"=>"Las Vegas", "state"=>"NV", "zip"=>"89101", "country"=>"US"},
          "status_details"=>"testing"
        },
        "tracking_history"=>[
          {
            "status"=>"UNKNOWN",
            "object_created"=>"2017-09-25T17:51:23.648",
            "status_date"=>"2017-09-25T17:51:23.648",
            "object_id"=>"8023f999c99149d08212a6dc1f15f1f4",
            "location"=>{"city"=>"Las Vegas", "state"=>"NV", "zip"=>"89101", "country"=>"US"},
            "status_details"=>"testing"
          }
        ],
        "transaction"=>nil
      },
      "event"=>"track_updated"
    }
  end


  it "should function" do
    FactoryGirl.create :customer_order, :with_shipping_label
    Ec::ShippingLabel.update_all(tracking_number: '123')

    webhook = Ec::ShippoTrackingWebhook.new(params)
    webhook.run!

    expect(Ec::ShippingLabel.count).to eq 1

    label = Ec::ShippingLabel.first

    expect(label.eta).to eq "2017-09-30T17:51:23.639"
    expect(label.tracking_status).to eq "UNKNOWN"
    expect(label.tracking_updated_at).to eq "2017-09-25T17:51:23.648"
    expect(label.tracking_payload).to be_present
  end
end
