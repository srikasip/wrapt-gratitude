class TrainingSet < ApplicationRecord
  belongs_to :survey

  has_many :gift_question_impacts, dependent: :destroy, inverse_of: :training_set

  has_one :evaluation, class_name: 'TrainingSetEvaluation', dependent: :destroy, inverse_of: :training_set

  scope :published, -> { where published: true}

  def publish!
    if !published?
      TrainingSet.transaction do
        TrainingSet.update_all published: false
        self.published = true
        save validate: false
      end
    end
  end

end
