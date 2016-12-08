module Admin
  class ConditionalQuestionOptionsController < ApplicationController
    # Ajax controller to drive selecting conditional question options on SurveyQuestions#edit

    def show
      @survey = Survey.find params[:survey_id]
      @survey_question = @survey.questions.find params[:question_id]
      @conditional_question = @survey.questions.find params[:id]
      @conditional_question_options = @survey_question.conditional_question_options
      render partial: 'show', locals: {conditional_question: @conditional_question}
    end
    

  end
end