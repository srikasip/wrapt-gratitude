class Parcel < ApplicationRecord
  USAGE_TYPES = ['pretty', 'shipping']

  validates :description,      presence: true
  validates :code,             presence: true, uniqueness: true
  validates :case_pack, numericality: { only_integer: true }, allow_nil: true
  validates :height_in_inches, numericality: { greater_than: 0 }
  validates :height_in_inches, presence: true
  validates :length_in_inches, numericality: { greater_than: 0 }
  validates :length_in_inches, presence: true
  validates :weight_in_pounds, numericality: { greater_than: 0 }
  validates :weight_in_pounds, presence: true
  validates :width_in_inches,  numericality: { greater_than: 0 }
  validates :width_in_inches,  presence: true
  validates :usage, inclusion: { in: USAGE_TYPES, message: "must be either #{USAGE_TYPES.first} or #{USAGE_TYPES.last}" }
  scope :active, -> { where(active: true) }

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
