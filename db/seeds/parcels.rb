OUNZE_TO_POUNDS = 0.0625

# Cardboard estimate
POUNDS_PER_SQUARE_INCH = 0.026 / (12 * 12)

parcels = [
  {
    active: true,
    case_pack: 100,
    code: 'A',
    color: 'Matte silver',
    description: "Box A: 3 ½” x 3 ½” x 1 ½”",
    height_in_inches: 1.5,
    length_in_inches: 3.5,
    source: 'Packaging Specialties',
    stock_number: 'JB331',
    usage: 'pretty',
    weight_in_pounds: (2 * OUNZE_TO_POUNDS),
    width_in_inches: 3.5,
  },

  {
    active: true,
    case_pack: 16,
    code: 'B',
    color: 'Matte silver',
    description: "Box B: 6” x 6” x 4” + 1 ½” lid",
    height_in_inches: (4 + 1.5),
    length_in_inches: 6,
    source: 'Packaging Specialties',
    stock_number: 'ABRS664',
    usage: 'pretty',
    weight_in_pounds: (6.2 * OUNZE_TO_POUNDS),
    width_in_inches: 6,
  },

  {
    active: true,
    case_pack: 8,
    code: 'C',
    color: 'Matte silver',
    description: "Box C: 12” x 12” x 6” + 1 ½” lid",
    height_in_inches: (6 + 1.5),
    length_in_inches: 12,
    source: 'Packaging Specialties',
    stock_number: 'ABRS12126',
    usage: 'pretty',
    weight_in_pounds: (23.5 * OUNZE_TO_POUNDS),
    width_in_inches: 12
  },

  {
    active: true,
    code: 'usps-flat-rate-small',
    description: "Small USPS flat-rate box",
    shippo_template_name: 'USPS_SmallFlatRateBox',
    weight_in_pounds: 5 * OUNZE_TO_POUNDS,
    height_in_inches: 1.75,
    length_in_inches: 8 + 11.0/16,
    width_in_inches:  5 + 7.0/16,
    usage: 'shipping'
  },

  {
    active: true,
    code: 'usps-flat-rate-med-1',
    description: "Medium USPS flat-rate box (top-loading)",
    shippo_template_name: 'USPS_MediumFlatRateBox1',
    weight_in_pounds: 6 * OUNZE_TO_POUNDS, #estimated
    height_in_inches: 6,
    length_in_inches: 11.25,
    width_in_inches: 8.75,
    usage: 'shipping'
  },

  {
    active: true,
    code: 'usps-flat-rate-med-2',
    description: "Medium USPS flat-rate box (type 2)",
    shippo_template_name: 'USPS_MediumFlatRateBox2',
    weight_in_pounds: 6 * OUNZE_TO_POUNDS, # estimated
    height_in_inches:  3.50,
    length_in_inches: 14.00,
    width_in_inches: 12.00,
    usage: 'shipping'
  },

  {
    active: true,
    code: 'shipping-a',
    description: 'Shipping Box: 12" x 12" x 8"',
    weight_in_pounds: 10 * OUNZE_TO_POUNDS, # estimated
    height_in_inches: 8.00,
    length_in_inches: 12.00,
    width_in_inches: 12.00,
    usage: 'shipping',
    shippo_template_name: nil
  },

  {
    active: true,
    code: 'shipping-b',
    description: '8"x6"x4"',
    weight_in_pounds: (8.0*6.0*2 + 6*4*2 + 4*8*2) * POUNDS_PER_SQUARE_INCH,
    height_in_inches: 8.00,
    length_in_inches: 6.00,
    width_in_inches: 4.00,
    usage: 'shipping',
    shippo_template_name: nil
  },

  {
    active: true,
    code: 'shipping-c',
    description: '14" x 14" x 7"',
    weight_in_pounds:  (14*14*2 + 14*7*4) * POUNDS_PER_SQUARE_INCH, # estimated
    height_in_inches: 7.00,
    length_in_inches: 14.00,
    width_in_inches: 14.00,
    usage: 'shipping',
    shippo_template_name: nil
  }
]

4.upto(14).each do |len|
  parcels << {
    active: true,
    code: "shipping-cube-#{len}-inch",
    description: "#{len}\"x#{len}\"x#{len}\"",
    weight_in_pounds: (len * len * 6) * POUNDS_PER_SQUARE_INCH,
    height_in_inches: len,
    length_in_inches: len,
    width_in_inches: len,
    usage: 'shipping',
    shippo_template_name: nil
  }
end

parcels.each do |data|
  parcel = Ec::Parcel.where(code: data[:code]).first_or_initialize
  parcel.assign_attributes(data)
  parcel.save!
end
