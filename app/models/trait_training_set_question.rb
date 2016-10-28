class TraitTrainingSetQuestion < ApplicationRecord
  belongs_to :trait_training_set
  belongs_to :question, class_name: 'SurveyQuestion'
  belongs_to :facet, class_name: 'ProfileTraits::Facet'

  has_many :trait_response_impacts, dependent: :destroy

end
