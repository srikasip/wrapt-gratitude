FactoryGirl.define do
  factory :shipment, class: Ec::Shipment do
    address_from {{
            "zip" => "66212",
           "city" => "Leawood",
           "name" => "Giraffe Home",
          "email" => "priscilla@giraffevashon.com",
          "phone" => "206 463-1372",
          "state" => "KS",
        "country" => "US",
        "street1" => "14325 Norwood",
        "street2" => nil,
        "street3" => nil
    }}

    address_to {{
            "zip" => "05301",
           "city" => "Dummerston",
           "name" => "Mr. Some Receiver",
          "email" => "example@example.com",
          "phone" => "123-123-1234",
          "state" => "VT",
        "country" => "US",
        "street1" => "319 Hague Rd",
        "street2" => "",
        "street3" => ""
    }}

    parcel  {{
                "width" => "6.0",
               "height" => "6.0",
               "length" => "6.0",
               "weight" => "10.25",
            "mass_unit" => "lb",
        "distance_unit" => "in"
    }}

    api_response {{ 'status' => 'SUCCESS' }}
  end
end
