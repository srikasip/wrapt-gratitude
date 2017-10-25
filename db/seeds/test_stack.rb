vendor = Vendor.where(name: 'Green River').first_or_initialize
vendor.assign_attributes({
  :contact_name                   => "Todd Blackman",
  :email                          => "tblackman@greenriver.com",
  :phone                          => "816-808-2890",
  :notes                          => "Account for testing on production. We want to be able to really charge and ship, but a $1 gift that weighs 1oz suffices for example. Do not delete.",
  :wrapt_sku_code                 => "GR",
  :street1                        => "167 Main Street",
  :city                           => "Brattleboro",
  :state                          => "VT",
  :zip                            => "05301",
  :country                        => "US",
  :street2                        => 'Suite 103',
  :purchase_order_markup_in_cents => 5
})
vendor.save!

product = vendor.products.where(title: 'Test Product').first_or_initialize
product.assign_attributes({
  :description            => "Test product",
  :price                  => 1.00,
  :vendor_retail_price    => 5.00,
  :wrapt_cost             => 0.50,
  :wrapt_sku              => 'TEST',
  :units_available        => 2,
  :vendor_sku             => "GR01",
  :notes                  => "Test product. Do not delete. This is used to test shipping and credit card charging.",
  :product_category_id    => 5,
  :product_subcategory_id => 29,
  :weight_in_pounds       => 0.50
})
product.save!

gift = Gift.where(title: "Test Gift").first_or_initialize
gift.assign_attributes({
  :description                    => "Test gift. Do not delete. This is used to test shipping and credit card charging.",
  :calculate_cost_from_products   => true,
  :calculate_price_from_products  => true,
  :product_category_id            => 5,
  :product_subcategory_id         => 29,
  :source_product                 => product,
  :featured                       => false,
  :calculate_weight_from_products => true,
  :wrapt_sku                      => 'TEST',
  :weight_in_pounds               => nil,
  :available                      => false,
  :insurance_in_dollars           => nil,
  :tax_code_id                    => 1
})
gift.save!

gp = gift.gift_products.first_or_initialize
gp.product = product
gp.save!

pretty = gift.pretty_parcels.first_or_initialize
pretty.parcel = Parcel.find_by(code: "A")
pretty.save!

ship = gift.shipping_parcels.first_or_initialize
ship.parcel = Parcel.find_by(code: "usps-flat-rate-small")
ship.save!
