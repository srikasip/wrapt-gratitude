class TrainingSetProductQuestion < ApplicationRecord
  belongs_to :training_set
  belongs_to :product
  belongs_to :survey_question
  self.model_name.instance_variable_set(:@route_key, "product_question")
  self.model_name.instance_variable_set(:@singular_route_key, "product_question")
end
