module BasicQuiz
  class ChangeProfilesController < ApplicationController
    include PjaxModalController
    
    before_filter :load_profile
    
    def new
      #select an existing profile to associated with the survey response
      # ask if they want to shop for profile they already have
      @disable_close = true
      @relationship_profiles = current_user.owned_profiles.
        active.where(relationship: @survey_response.profile.relationship)
    end
    
    def created
      #create a new survey response on the selected profile
      #copy the last set of survey responses from that profile
      #merge in any responses from the current survey response
      selected_profile = current_user.owned_profiles.active.find(params[:selected_profile_id])
      
      builder = Recommender::SurveyResponseBuilder.new(selected_profile)
      
      SurveyResponse.transaction do
        builder.copy!
        builder.merge!(@survey_response)
        @survey_response.profile.destroy
      end
      
      redirect_to new_basic_quiz_profile_recommendation_set_path(selected_profile)
    end
    
    def load_profile
      current_user.owned_profiles.find(params[:profile_id])
    end
  end
end

