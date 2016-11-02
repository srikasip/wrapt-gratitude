class ProfileTraits::Tag < ApplicationRecord
  belongs_to :facet, class_name: 'ProfileTraits::Facet'

  has_many :trait_response_impacts, dependent: :destroy

  validates :position, numericality: {greater_than_or_equal_to: -3, less_than_or_equal_to: 3}

  def name_with_position
    "#{name} (#{position})"
  end

end
