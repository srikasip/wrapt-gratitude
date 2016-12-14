class NullSurveySection
  include ActiveModel::Model

  attr_accessor :survey

  def questions
    survey.questions.where(survey_section_id: nil).order(:sort_order)
  end

  def id
    nil
  end

  def name
    "Uncategorized"
  end

  def sort_order
    99999
  end

  def == other
    other.is_a? NullSurveySection
  end
end