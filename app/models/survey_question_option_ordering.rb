class SurveyQuestionOptionOrdering

  attr_reader :survey_question, :ordering

  def initialize attrs
    @survey_question = attrs.fetch :survey_question
    @ordering = attrs.fetch :ordering
  end

  def save
    survey_question_questions = @survey_question.options.to_a
    ordering.each_with_index do |option_id, i|
      survey_question_questions.detect{|option| option.id == option_id.to_i}.update sort_order: i+1
    end
  end


end