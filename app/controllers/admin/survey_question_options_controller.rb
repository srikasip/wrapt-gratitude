module Admin
  class SurveyQuestionOptionsController < BaseController
    # Ajax controller to control the survey builder
    before_action :set_survey
    before_action :set_survey_question
    before_action :set_survey_question_option, except: :create
    layout 'xhr'

    helper SurveyQuestionsHelper

    def show
      render 'survey_questions/_option_row', locals: {option: @survey_question_option}
    end

    def create
      @survey_question_option = @survey_question.options.new(survey_question_option_params)
      
      if @survey_question_option.save
        render 'survey_questions/_option_row', locals: {option: @survey_question_option}
      else
        head :bad_request
      end
    end

    def edit
    end

    def update    
      if @survey_question_option.update(survey_question_option_params)
        render 'survey_questions/_option_row', locals: {option: @survey_question_option}
      else
        head :bad_request
      end
    end

    def destroy
      @survey_question_option.destroy
      head :ok
    end

    private
    def set_survey
      @survey = Survey.find(params[:survey_id])
    end

    def set_survey_question
      @survey_question = @survey.questions.find(params[:question_id])
    end

    def set_survey_question_option
      @survey_question_option = @survey_question.options.find params[:id]
    end

    def survey_question_option_params
      params.require(:survey_question_option).permit(:text)
    end

  end
end