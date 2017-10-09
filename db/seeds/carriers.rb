carrier_names = [
  'FedEx',
  'UPS',
  'USPS'
]

carrier_names.each do |name|
  carrier = ShippingCarrier.where(name: name).first_or_initialize
  carrier.shippo_provider_name = name
  carrier.save!
end

service_level_params = [
  {provider: "USPS", name: "Priority Mail Express", :token =>"usps_priority_express", :estimated_days=>2, :terms=>"Overnight delivery to most U.S. locations."},
  {provider: "USPS", name: "Priority Mail",         :token =>"usps_priority", :estimated_days=>2, :terms=>"Delivery within 1, 2, or 3 days based on where your package started and where it’s being sent."},
  {provider: "USPS", name: "Parcel Select",         :token =>"usps_parcel_select", :estimated_days=>7, :terms=>"Delivery in 2 to 8 days."},
  {provider: 'USPS', estimated_days: 10, terms: "unknown", token: 'usps_first',                                     name: "First Class Mail/Package"},
  {provider: 'USPS', estimated_days: 10, terms: "unknown", token: 'usps_parcel_select',                             name: "Parcel Select"},
  {provider: 'USPS', estimated_days: 10, terms: "unknown", token: 'usps_priority_mail_international',               name: "Priority Mail International"},
  {provider: 'USPS', estimated_days: 10, terms: "unknown", token: 'usps_priority_mail_express_international',       name: "Priority Mail Express International"},
  {provider: 'USPS', estimated_days: 10, terms: "unknown", token: 'usps_first_class_package_international_service', name: "First Class Package International"},

  {provider: "FedEx", name: "Ground",             token: "fedex_ground",             estimated_days: 3, terms: "unknown"},
  {provider: "FedEx", name: "Express Saver",      token: "fedex_express_saver",      estimated_days: 5, terms: "unknown"},
  {provider: "FedEx", name: "2 Day",              token: "fedex_2_day",              estimated_days: 4, terms: "unknown"},
  {provider: "FedEx", name: "2 Day A.M.",         token: "fedex_2_day_am",           estimated_days: 3, terms: "unknown"},
  {provider: "FedEx", name: "Standard Overnight", token: "fedex_standard_overnight", estimated_days: 1, terms: "unknown"},
  {provider: "FedEx", name: "Priority Overnight", token: "fedex_priority_overnight", estimated_days: 0, terms: "unknown"},
  {provider: "FedEx", name: "First Overnight",    token: "fedex_first_overnight",    estimated_days: 0, terms: "unknown"},
  {provider: "FedEx", name: "Express Saver",      token: "fedex_express_saver",      estimated_days: 3, terms: "unknown"},
  {provider: "FedEx", name: "2 Day",              token: "fedex_2_day",              estimated_days: 2, terms: "unknown"},
  {provider: "FedEx", name: "2 Day A.M.",         token: "fedex_2_day_am",           estimated_days: 2, terms: "unknown"},
  {provider: "FedEx", name: "Priority Overnight", token: "fedex_priority_overnight", estimated_days: 1, terms: "unknown"},
  {provider: "FedEx", name: "First Overnight",    token: "fedex_first_overnight",    estimated_days: 1, terms: "unknown"},
  {provider: "FedEx", name: "2 Day A.M.",         token: "fedex_2_day_am",           estimated_days: 4, terms: "unknown"},
  {provider: "FedEx", name: "Standard Overnight", token: "fedex_standard_overnight", estimated_days: 3, terms: "unknown"},
  {provider: "FedEx", name: "Priority Overnight", token: "fedex_priority_overnight", estimated_days: 3, terms: "unknown"},
  {provider: "FedEx", name: "First Overnight",    token: "fedex_first_overnight",    estimated_days: 2, terms: "unknown"},
  {provider: "FedEx", name: "Priority Overnight", token: "fedex_priority_overnight", estimated_days: 2, terms: "unknown"},
  {provider: "FedEx", name: "Ground",             token: "fedex_ground",             estimated_days: 1, terms: "unknown"},

  {provider: 'UPS', token: 'ups_standard',                  estimated_days: 10, terms: "unknown", name: "Standard℠"},
  {provider: 'UPS', token: 'ups_ground',                    estimated_days: 10, terms: "unknown", name: "Ground"},
  {provider: 'UPS', token: 'ups_saver',                     estimated_days: 10, terms: "unknown", name: "Saver®"},
  {provider: 'UPS', token: 'ups_3_day_select',              estimated_days: 10, terms: "unknown", name: "Three-Day Select®"},
  {provider: 'UPS', token: 'ups_second_day_air',            estimated_days: 10, terms: "unknown", name: "Second Day Air®"},
  {provider: 'UPS', token: 'ups_second_day_air_am',         estimated_days: 10, terms: "unknown", name: "Second Day Air A.M.®"},
  {provider: 'UPS', token: 'ups_next_day_air',              estimated_days: 10, terms: "unknown", name: "Next Day Air®"},
  {provider: 'UPS', token: 'ups_next_day_air_saver',        estimated_days: 10, terms: "unknown", name: "Next Day Air Saver®"},
  {provider: 'UPS', token: 'ups_next_day_air_early_am',     estimated_days: 10, terms: "unknown", name: "Next Day Air Early A.M.®"},
  {provider: 'UPS', token: 'ups_mail_innovations_domestic', estimated_days: 10, terms: "unknown", name: "Mail Innovations (domestic)"},
  {provider: 'UPS', token: 'ups_surepost',                  estimated_days: 10, terms: "unknown", name: "Surepost"},
  {provider: 'UPS', token: 'ups_surepost_lightweight',      estimated_days: 10, terms: "unknown", name: "Surepost Lightweight"},
  {provider: 'UPS', token: 'ups_express',                   estimated_days: 10, terms: "unknown", name: "Express®"},
  {provider: 'UPS', token: 'ups_express_plus',              estimated_days: 10, terms: "unknown", name: "Express Plus®"},
  {provider: 'UPS', token: 'ups_expedited',                 estimated_days: 10, terms: "unknown", name: "Expedited®"},
]


service_level_params.each do |_p|
  p = OpenStruct.new(_p)

  ssl = ShippingServiceLevel.where(shippo_token: p.token).first_or_initialize

  ssl.shipping_carrier = ShippingCarrier.find_by(name: p.provider)

  ssl.estimated_days = p.estimated_days
  ssl.name = p.name
  ssl.terms = p.terms

  ssl.save!
end
