class ProfileTraits::Tag < ApplicationRecord
  belongs_to :facet, class_name: 'ProfileTraits::Facet'
end
