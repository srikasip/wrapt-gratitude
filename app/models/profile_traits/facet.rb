class ProfileTraits::Facet < ApplicationRecord
  belongs_to :topic, class_name: 'ProfileTraits::Topic'
  has_many :tags, class_name: 'ProfileTraits::Tag', inverse_of: :facet, dependent: :destroy
end
