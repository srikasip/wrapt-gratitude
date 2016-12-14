module Admin
  class ProfileSetSurveyResponsesController < BaseController
    before_action :set_profile_set
    before_action :set_profile_set_survey_response, only: [:show, :edit, :update, :destroy]

    def new
      @profile_set_survey_response = @profile_set.survey_responses.new
    end

    def edit
    end

    def create
      @profile_set_survey_response = @profile_set.survey_responses.new(profile_set_survey_response_params)

      if @profile_set_survey_response.save
        redirect_to edit_admin_profile_set_survey_response_path(@profile_set, @profile_set_survey_response), notice: 'Quiz Response was successfully created.  Now Answer the Questions.'
        else
          render :new
        end
      end

    def update
      if @profile_set_survey_response.update(profile_set_survey_response_params)
        redirect_to [:admin, @profile_set], notice: 'Quiz Response was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @profile_set_survey_response.destroy
      redirect_to [:admin, @profile_set], notice: 'Quiz Response was successfully deleted.'
    end

    private
      def set_profile_set
        @profile_set = ProfileSet.find params[:profile_set_id]
      end

      def set_profile_set_survey_response
        @profile_set_survey_response = @profile_set.survey_responses.find(params[:id])
      end

      def profile_set_survey_response_params
        params.require(:profile_set_survey_response).permit(
          :name,
          question_responses_attributes: [
            :id,
            :text_response,
            :range_response,
            :other_option_text,
            :survey_question_id,
            :survey_question_option_id,
            survey_question_option_ids: [],
          ]
        )
      end
  end
end
