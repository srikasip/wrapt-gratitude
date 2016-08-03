class TrainingSetResponseImpact < ApplicationRecord
  belongs_to :training_set_product_question
  belongs_to :survey_question_option

  enum impact: {
    none: 0,
    positive: 1
    strongly_positive: 10
    negative: -1
    never_recommend: -10
  }
end
