module Admin
  class SurveyQuestionsController < BaseController
    before_action :set_survey
    before_action :set_survey_question, only: [:show, :edit, :update, :destroy, :preview]

    helper ::Admin::ConditionalQuestionOptionsHelper

    def new
      @survey_question = @survey.questions.new
    end

    def edit
      @conditional_question = @survey_question.conditional_question
      @conditional_question_options = @survey_question.conditional_question_options
      if @survey_question.is_a? ::SurveyQuestions::MultipleChoice
        @survey_question_option = SurveyQuestionOption.new
        @options = @survey_question.options.standard
        render :edit_multiple_choice
      end
    end

    def create
      @survey_question = @survey.questions.new(create_params)
      
      if @survey_question.save
        redirect_to edit_admin_survey_question_path(@survey, @survey_question), notice: 'The question was successfully created.'
      else
        render :new
      end
    end

    def update
      if @survey_question.update(update_params)
        redirect_to edit_admin_survey_question_path(@survey, @survey_question), notice: 'The question was successfully updated.'
      else
        @conditional_question = @survey_question.conditional_question
        @conditional_question_options = @survey_question.conditional_question_options
        render :edit
      end
    end

    def destroy
      @survey_question.destroy
      redirect_to admin_survey_url(@survey), notice: 'The question was successfully deleted.'
    end

    # ajax member action for multi-choice edit
    def preview
      render '_preview', layout: 'xhr'
    end

    private
    def set_survey
      @survey = Survey.find(params[:survey_id])
    end

    def set_survey_question
      @survey_question = @survey.questions.find(params[:id])
    end

    def create_params
      params.require(:survey_question).permit(:prompt, :type, :survey_section_id)
    end

    def update_params
      result = params.require(@survey_question.model_name.param_key).permit(
          :prompt,
          :min_label,
          :max_label,
          :mid_label,
          :code,
          :include_other_option,
          :multiple_option_responses,
          :use_response_as_name,
          :code,
          :conditional_display,
          :conditional_question_id,
          :survey_section_id,
          :yes_no_display,
          conditional_question_option_option_ids: []
        )
      if result[:conditional_display] == "0"
        result[:conditional_question_id] = nil
        result[:conditional_question_option_option_ids] = []
      end
      return result
    end

  end
end