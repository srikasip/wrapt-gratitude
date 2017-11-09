require "rails_helper"

describe PurchaseService::ShippingService do
  let(:path)           { File.join(Rails.root, 'spec', 'fixtures', 'shippo.payload.rb') }
  let(:payload)        { eval(File.read(path)) }
  let(:customer_order) { FactoryGirl.create :customer_order, :with_shipping_label }
  let(:mailer_double)  { double('Customer Order Mail').as_null_object }
  let(:vendor)         { Vendor.find_by(name: 'Green River') }
  let(:rates) do
     json = "[{\"test\":false,\"zone\":null,\"amount\":\"46.09\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"UPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"8a70883d3e4e4bcb916e1f067175752f\",\"arrives_by\":\"10:30:00\",\"attributes\":[],\"amount_local\":\"46.09\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Next Day Air®\",\"terms\":\"\",\"token\":\"ups_next_day_air\"},\"currency_local\":\"USD\",\"duration_terms\":\"Next business day delivery by 10:30 a.m., 12:00 noon, or end of day, depending on destination.\",\"estimated_days\":1,\"object_created\":\"2017-11-09T16:50:20.011Z\",\"carrier_account\":\"0b9a7b374c67401689872b4d35882bb5\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/UPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/UPS.png\"},{\"test\":false,\"zone\":null,\"amount\":\"77.89\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"UPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"9d6fa8d541dc458eb970017346266eb6\",\"arrives_by\":\"08:30:00\",\"attributes\":[],\"amount_local\":\"77.89\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Next Day Air Early A.M.®\",\"terms\":\"\",\"token\":\"ups_next_day_air_early_am\"},\"currency_local\":\"USD\",\"duration_terms\":\"Next business day delivery by 8:30 a.m., 9:00 a.m., or 9:30 a.m. \",\"estimated_days\":1,\"object_created\":\"2017-11-09T16:50:20.010Z\",\"carrier_account\":\"0b9a7b374c67401689872b4d35882bb5\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/UPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/UPS.png\"},{\"test\":false,\"zone\":null,\"amount\":\"42.43\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"UPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"b40b5e073a5242fb941dc22b95e7cc69\",\"arrives_by\":\"15:00:00\",\"attributes\":[],\"amount_local\":\"42.43\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Next Day Air Saver®\",\"terms\":\"\",\"token\":\"ups_next_day_air_saver\"},\"currency_local\":\"USD\",\"duration_terms\":\"Next business day delivery by 3:00 or 4:30 p.m. for commercial destinations and by end of day for residentail destinations.\",\"estimated_days\":1,\"object_created\":\"2017-11-09T16:50:20.009Z\",\"carrier_account\":\"0b9a7b374c67401689872b4d35882bb5\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/UPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/UPS.png\"},{\"test\":false,\"zone\":null,\"amount\":\"26.10\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"UPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"931b08f1fbb94eddbf3f5f24c0be5b5a\",\"arrives_by\":null,\"attributes\":[],\"amount_local\":\"26.10\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Second Day Air®\",\"terms\":\"\",\"token\":\"ups_second_day_air\"},\"currency_local\":\"USD\",\"duration_terms\":\"Delivery by the end of the second business day.\",\"estimated_days\":2,\"object_created\":\"2017-11-09T16:50:20.008Z\",\"carrier_account\":\"0b9a7b374c67401689872b4d35882bb5\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/UPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/UPS.png\"},{\"test\":false,\"zone\":null,\"amount\":\"20.17\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"UPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"e0086f436a1d4e929376b60a36328e8a\",\"arrives_by\":null,\"attributes\":[],\"amount_local\":\"20.17\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Three-Day Select®\",\"terms\":\"\",\"token\":\"ups_3_day_select\"},\"currency_local\":\"USD\",\"duration_terms\":\"Delivery by the end of the third business day.\",\"estimated_days\":3,\"object_created\":\"2017-11-09T16:50:20.007Z\",\"carrier_account\":\"0b9a7b374c67401689872b4d35882bb5\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/UPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/UPS.png\"},{\"test\":false,\"zone\":null,\"amount\":\"13.56\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"UPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"2845c9128b344de696a4612ab0e205df\",\"arrives_by\":null,\"attributes\":[],\"amount_local\":\"13.56\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Ground\",\"terms\":\"\",\"token\":\"ups_ground\"},\"currency_local\":\"USD\",\"duration_terms\":\"Delivery times vary. Delivered usually in 1-5 business days.\",\"estimated_days\":4,\"object_created\":\"2017-11-09T16:50:20.006Z\",\"carrier_account\":\"0b9a7b374c67401689872b4d35882bb5\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/UPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/UPS.png\"},{\"test\":false,\"zone\":\"2\",\"amount\":\"9.32\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"FedEx\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"22cd5bb6c9d44383a99960bd74d88d2e\",\"arrives_by\":null,\"attributes\":[],\"amount_local\":\"9.32\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Ground\",\"terms\":\"\",\"token\":\"fedex_ground\"},\"currency_local\":\"USD\",\"duration_terms\":\"\",\"estimated_days\":1,\"object_created\":\"2017-11-09T16:50:19.547Z\",\"carrier_account\":\"1dc9b1708d82476291ffed6b2d8f1d23\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/FedEx.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/FedEx.png\"},{\"test\":false,\"zone\":\"02\",\"amount\":\"16.32\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"FedEx\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"0d0fd183f9f144f6aa323a994af54d08\",\"arrives_by\":\"16:30:00\",\"attributes\":[],\"amount_local\":\"16.32\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Express Saver\",\"terms\":\"\",\"token\":\"fedex_express_saver\"},\"currency_local\":\"USD\",\"duration_terms\":\"\",\"estimated_days\":5,\"object_created\":\"2017-11-09T16:50:19.546Z\",\"carrier_account\":\"1dc9b1708d82476291ffed6b2d8f1d23\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/FedEx.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/FedEx.png\"},{\"test\":false,\"zone\":\"02\",\"amount\":\"18.92\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"FedEx\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"6183a818c006494ca103c6277fd23456\",\"arrives_by\":\"16:30:00\",\"attributes\":[],\"amount_local\":\"18.92\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"2 Day\",\"terms\":\"\",\"token\":\"fedex_2_day\"},\"currency_local\":\"USD\",\"duration_terms\":\"\",\"estimated_days\":4,\"object_created\":\"2017-11-09T16:50:19.546Z\",\"carrier_account\":\"1dc9b1708d82476291ffed6b2d8f1d23\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/FedEx.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/FedEx.png\"},{\"test\":false,\"zone\":\"02\",\"amount\":\"21.12\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"FedEx\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"2c766aaac0eb48499d67e721e623ac86\",\"arrives_by\":\"10:30:00\",\"attributes\":[],\"amount_local\":\"21.12\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"2 Day A.M.\",\"terms\":\"\",\"token\":\"fedex_2_day_am\"},\"currency_local\":\"USD\",\"duration_terms\":\"\",\"estimated_days\":3,\"object_created\":\"2017-11-09T16:50:19.545Z\",\"carrier_account\":\"1dc9b1708d82476291ffed6b2d8f1d23\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/FedEx.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/FedEx.png\"},{\"test\":false,\"zone\":\"02\",\"amount\":\"32.29\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"FedEx\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"8502fa38f86d4b64b3ee7d9810cc3cc5\",\"arrives_by\":\"15:00:00\",\"attributes\":[],\"amount_local\":\"32.29\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Standard Overnight\",\"terms\":\"\",\"token\":\"fedex_standard_overnight\"},\"currency_local\":\"USD\",\"duration_terms\":\"\",\"estimated_days\":1,\"object_created\":\"2017-11-09T16:50:19.544Z\",\"carrier_account\":\"1dc9b1708d82476291ffed6b2d8f1d23\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/FedEx.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/FedEx.png\"},{\"test\":false,\"zone\":\"02\",\"amount\":\"34.15\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"FedEx\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"5452043dfd614de2a6c20e32875c11c2\",\"arrives_by\":\"10:30:00\",\"attributes\":[],\"amount_local\":\"34.15\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Priority Overnight\",\"terms\":\"\",\"token\":\"fedex_priority_overnight\"},\"currency_local\":\"USD\",\"duration_terms\":\"\",\"estimated_days\":0,\"object_created\":\"2017-11-09T16:50:19.543Z\",\"carrier_account\":\"1dc9b1708d82476291ffed6b2d8f1d23\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/FedEx.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/FedEx.png\"},{\"test\":false,\"zone\":\"02\",\"amount\":\"70.97\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"FedEx\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"44877b9baabb427cbb06edcc148182eb\",\"arrives_by\":\"08:00:00\",\"attributes\":[],\"amount_local\":\"70.97\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"First Overnight\",\"terms\":\"\",\"token\":\"fedex_first_overnight\"},\"currency_local\":\"USD\",\"duration_terms\":\"\",\"estimated_days\":0,\"object_created\":\"2017-11-09T16:50:19.542Z\",\"carrier_account\":\"1dc9b1708d82476291ffed6b2d8f1d23\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/FedEx.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/FedEx.png\"},{\"test\":false,\"zone\":\"1\",\"amount\":\"30.49\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"USPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"8eaad8cde4854fb18163b1e2330d5c9d\",\"arrives_by\":null,\"attributes\":[],\"amount_local\":\"30.49\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Priority Mail Express\",\"terms\":\"\",\"token\":\"usps_priority_express\"},\"currency_local\":\"USD\",\"duration_terms\":\"Overnight delivery to most U.S. locations.\",\"estimated_days\":2,\"object_created\":\"2017-11-09T16:50:18.902Z\",\"carrier_account\":\"e1d459fbab0b4683b67c593a46797382\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/USPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/USPS.png\"},{\"test\":false,\"zone\":\"1\",\"amount\":\"8.09\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"USPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"2cc50e7446514a328f282377ec148ac1\",\"arrives_by\":null,\"attributes\":[\"BESTVALUE\",\"CHEAPEST\"],\"amount_local\":\"8.09\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Priority Mail\",\"terms\":\"\",\"token\":\"usps_priority\"},\"currency_local\":\"USD\",\"duration_terms\":\"Delivery within 1, 2, or 3 days based on where your package started and where it’s being sent.\",\"estimated_days\":2,\"object_created\":\"2017-11-09T16:50:18.901Z\",\"carrier_account\":\"e1d459fbab0b4683b67c593a46797382\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/USPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/USPS.png\"},{\"test\":false,\"zone\":\"1\",\"amount\":\"8.09\",\"currency\":\"USD\",\"messages\":[],\"provider\":\"USPS\",\"shipment\":\"bb6e4c1c1a6b4871a31536954fd7a5e4\",\"object_id\":\"5c1f46f90c034aa1b8014db44118c028\",\"arrives_by\":null,\"attributes\":[],\"amount_local\":\"8.09\",\"object_owner\":\"mj@wrapt.com\",\"servicelevel\":{\"name\":\"Parcel Select\",\"terms\":\"\",\"token\":\"usps_parcel_select\"},\"currency_local\":\"USD\",\"duration_terms\":\"Delivery in 2 to 8 days.\",\"estimated_days\":7,\"object_created\":\"2017-11-09T16:50:18.900Z\",\"carrier_account\":\"e1d459fbab0b4683b67c593a46797382\",\"provider_image_75\":\"https://shippo-static.s3.amazonaws.com/providers/75/USPS.png\",\"provider_image_200\":\"https://shippo-static.s3.amazonaws.com/providers/200/USPS.png\"}]"
     #" SyntaxHighlightFIXER
     JSON.parse(json)
  end

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

  it "should sort rates" do
    fastest = PurchaseService::ShippingService.find_rate(rates: rates, shipping_choice: 'FASTEST', vendor: vendor)
    cheapest = PurchaseService::ShippingService.find_rate(rates: rates, shipping_choice: 'CHEAPEST', vendor: vendor)

    # The test data has a tie for fastest and this is the cheapest
    expect(fastest.dig('servicelevel', 'token')).to eq("fedex_priority_overnight")

    # The test data has a tie for cheapest at $8.09 but USPS priority is the faster of the two
    expect(cheapest.dig('servicelevel', 'token')).to eq("usps_priority")
  end
end
