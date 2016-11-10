class ProfileTraits::Tag < ApplicationRecord
  belongs_to :facet, class_name: 'ProfileTraits::Facet'

  has_many :trait_response_impacts, dependent: :destroy, foreign_key: 'profile_traits_tag_id'

  validates :position, inclusion: {in: (-3..3), message: "must be between -3 and 3"}

  def name_with_position
    "#{name} (#{position})"
  end

end
