class SurveyPublishing
  include ActiveModel::Model

  attr_accessor :survey_id
  validates :survey_id, presence: true

  def survey
    @survey = Survey.where(id: survey_id).first
  end

  def save
    if valid?
      survey.publish!
      return true
    else
      return false
    end
  end

  def persisted
    false
  end
end