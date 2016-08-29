class SurveyQuestionOrdering

  attr_reader :survey, :ordering

  def initialize attrs
    @survey = attrs.fetch :survey
    @ordering = attrs.fetch :ordering
  end

  def save
    survey_questions = @survey.questions.to_a
    ordering.each_with_index do |question_id, i|
      survey_questions.detect{|question| question.id == question_id.to_i}.update sort_order: i+1
    end
  end


end