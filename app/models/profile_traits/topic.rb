module ProfileTraits
  class Topic < ApplicationRecord
    has_many :facets, class_name: 'ProfileTraits::Facet', inverse_of: :topic, dependent: :destroy
  end
end
