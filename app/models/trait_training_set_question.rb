class TraitTrainingSetQuestion < ApplicationRecord
  belongs_to :trait_training_set, touch: true
  belongs_to :question, class_name: 'SurveyQuestion'
  belongs_to :facet, class_name: 'ProfileTraits::Facet'

  has_many :trait_response_impacts, dependent: :destroy

  accepts_nested_attributes_for :trait_response_impacts, allow_destroy: true

end
