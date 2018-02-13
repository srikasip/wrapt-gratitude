module BasicQuiz
  class ChangeProfilesController < ApplicationController
    include PjaxModalController
    
    before_filter :load_profile

    def login_required?
      true
    end
    
    def new
      # select an existing profile to associated with the survey response
      @disable_close = true
      @relationship_profiles = current_user.owned_profiles.
        active.where(relationship: @survey_response.profile.relationship)
    end
    
    def create
      # create a new survey response on the selected profile
      # copy the last set of survey responses from the selected profile
      # merge in any responses from the current survey response
      selected_profile = current_user.owned_profiles.active.find(params[:change_profile][:profile_id])
      
      builder = Recommender::SurveyResponseBuilder.new(selected_profile)
      
      SurveyResponse.transaction do
        builder.copy!
        builder.merge!(@survey_response)
        # destroy the models if they are single purpose
        #@survey_response.destroy
        #@profile.destroy if @profile.survey_responses.none?
      end
      
      @profile = builder.profile
      @survey_response = builder.survey_response
      @question_responses = builder.order_question_responses(
        first: %w{whatlike spend},
        last: 'occassion'
      )
      
      # invalidate any existing rec sets so they can get a fresh set
      # of recommendations for this profile
      @profile.gift_recommendation_sets.update_all(stale: true)
      
      render :edit
    end
    
    def load_profile
      @profile = current_user.owned_profiles.find(params[:profile_id])
      @survey_response = @profile.last_survey
    end
    
  end
end

