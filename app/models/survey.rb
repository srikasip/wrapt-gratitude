class Survey < ApplicationRecord

  has_many :questions, class_name: 'SurveyQuestion', dependent: :destroy, inverse_of: :survey

end
