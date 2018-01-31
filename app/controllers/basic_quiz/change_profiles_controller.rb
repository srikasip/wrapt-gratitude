module BasicQuiz
  class ChangeProfilesController < ApplicationController
    include PjaxModalController
    
    before_filter :load_profile

    def login_required?
      true
    end
    
    def new
      # select an existing profile to associated with the survey response
      # ask if they want to shop for profile they already have
      @disable_close = true
      @relationship_profiles = current_user.owned_profiles.
        active.where(relationship: @survey_response.profile.relationship)
    end
    
    def created
      # create a new survey response on the selected profile
      # copy the last set of survey responses from the selected profile
      # merge in any responses from the current survey response
      selected_profile = current_user.owned_profiles.active.find(params[:change_profile][:profile_id])
      
      builder = Recommender::SurveyResponseBuilder.new(selected_profile)
      
      SurveyResponse.transaction do
        builder.copy!
        builder.merge!(@survey_response)
        # destroy the models if they are single purpose
        @survey_response.destroy
        @profile.destroy if @profile.survey_responses.none?
      end
      
      redirect_to new_basic_quiz_profile_recommendation_set_path(selected_profile)
    end
    
    def load_profile
      @profile = current_user.owned_profiles.find(params[:profile_id])
      @survey_response = @profile.last_survey
    end
  end
end

