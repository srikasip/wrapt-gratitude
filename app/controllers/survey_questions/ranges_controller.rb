module SurveyQuestions
  class RangesController < ApplicationController
    before_action :set_survey
    before_action :set_survey_question, only: [:show, :edit, :update, :destroy]

    def new
      @survey_question = @survey.range_questions.new
    end

    def edit
    end

    def create
      @survey_question = @survey.range_questions.new(survey_params)
      
      if @survey_question.save
        redirect_to survey_path(@survey), notice: 'Quiz Question was successfully created.'
      else
        render :new
      end
    end

    def update    
      if @survey_question.update(survey_params)
        redirect_to survey_path(@survey), notice: 'Quiz Question was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @survey.destroy
      redirect_to surveys_url, notice: 'Quiz was successfully deleted.'
    end

    private
      def set_survey
        @survey = Survey.find(params[:survey_id])
      end

      def set_survey_question
        @survey_question = @survey.range_questions.find(params[:id])
      end

      def survey_params
        params.require(:survey_questions_range).permit(:prompt, :min_label, :max_label, :mid_label, :secondary_prompt)
      end

  end
end
