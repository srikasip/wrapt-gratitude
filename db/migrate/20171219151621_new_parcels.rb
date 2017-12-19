class NewParcels < ActiveRecord::Migration[5.0]
  OUNZE_TO_POUNDS = 0.0625

  def change
    parcels = [
      {
        active: true,
        code: 'usps-flat-rate-envelope',
        description: "USPS flat-rate envelope",
        shippo_template_name: 'USPS_FlatRateEnvelope',
        weight_in_pounds: 0.5 * OUNZE_TO_POUNDS, # estimated
        height_in_inches: 9.5,
        length_in_inches: 12.5,
        width_in_inches: 0.75,
        usage: 'shipping'
      },
      {
        active: true,
        code: 'no-gift-box',
        description: "No Gift Box",
        height_in_inches: 0.01,
        length_in_inches: 0.01,
        usage: 'pretty',
        weight_in_pounds: 0.01,
        width_in_inches: 0.01,
      }
    ]

    parcels.each do |data|
      parcel = Ec::Parcel.where(code: data[:code]).first_or_initialize
      parcel.assign_attributes(data)
      parcel.save!
    end

  end
end
