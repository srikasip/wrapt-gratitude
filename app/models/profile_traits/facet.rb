class ProfileTraits::Facet < ApplicationRecord
  belongs_to :topic, class_name: 'ProfileTraits::Topic'
end
