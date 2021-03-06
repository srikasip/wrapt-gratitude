class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :street1, presence: true
  validates :street1, length: { minimum: 3 }
  validates :city, presence: true
  validates :state, presence: true
  validates :state, inclusion: { in: UsaState.abbreviations }
  validates :zip, presence: true
  validates :zip, length: { within: 5..10}
  validates :country, inclusion: { in: ['US'], message: 'only supports US right now' }

  def ship_address_is_equal_to_address?(ship_address)
    address_values_to_compare = [street1, city, state, zip]
    ship_attrs = [:ship_street1, :ship_city, :ship_state, :ship_zip]
    equal = true
    address_values_to_compare.each_with_index do |v, i|
      if v.downcase != ship_address.send(ship_attrs[i]).downcase
        equal = false
      end
    end
    equal
  end
end
