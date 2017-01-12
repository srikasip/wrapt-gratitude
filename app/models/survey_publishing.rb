class SurveyPublishing
  include ActiveModel::Model

  attr_accessor :survey_id, :training_set_id
  validates :survey_id, presence: true
  validates :training_set_id, presence: true

  def survey
    @survey = Survey.where(id: survey_id).first
  end

  def training_set
    @training_set = TrainingSet.where(id: training_set_id).first
  end

  def save
    if valid?
      survey.publish!
      training_set.publish!
      return true
    else
      return false
    end
  end

  def persisted
    false
  end
end