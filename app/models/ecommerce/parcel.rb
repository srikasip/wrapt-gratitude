class Parcel < ApplicationRecord
  validates :description,      presence: true
  validates :height_in_inches, numericality: { greater_than: 0 }
  validates :height_in_inches, presence: true
  validates :length_in_inches, numericality: { greater_than: 0 }
  validates :length_in_inches, presence: true
  validates :weight_in_pounds, numericality: { greater_than: 0 }
  validates :weight_in_pounds, presence: true
  validates :width_in_inches,  numericality: { greater_than: 0 }
  validates :width_in_inches,  presence: true

  def self.dummy_parcel
    @dummy_parcel ||= create!({
      description: '6 Inch Cube (dummy)',
      height_in_inches: 6,
      length_in_inches: 6,
      weight_in_pounds: 0.25,
      width_in_inches: 6,
    })
  end

  def as_shippo_hash
    {
      length:        self.length_in_inches,
      width:         self.width_in_inches,
      height:        self.height_in_inches,
      distance_unit: :in,
      weight:        self.weight_in_pounds,
      mass_unit:     :lb
    }
  end
end
