module Admin
  class SurveyQuestionOptionImagesController < BaseController
    # Ajax controller to control the survey builder
    before_action :set_survey
    before_action :set_survey_question
    before_action :set_survey_question_option
    layout 'xhr'

    helper ::Admin::SurveyQuestionsHelper

    def edit
    end

    def update    
      if @survey_question_option.update(survey_question_option_params)
        render 'admin/survey_questions/_option_row', locals: {option: @survey_question_option}
      else
        head :bad_request
      end
    end

    def destroy
      @survey_question_option.remove_image!
      @survey_question_option.save!
      render 'admin/survey_questions/_option_row', locals: {option: @survey_question_option}
    end

    private
    def set_survey
      @survey = Survey.find(params[:survey_id])
    end

    def set_survey_question
      @survey_question = @survey.questions.find(params[:question_id])
    end

    def set_survey_question_option
      @survey_question_option = @survey_question.options.find params[:option_id]
    end

    def survey_question_option_params
      params.require(:survey_question_option).permit(:image)
    end

  end
end