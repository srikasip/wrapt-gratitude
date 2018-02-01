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
      
      set_question_responses
      
      render :edit
    end
    
    def load_profile
      @profile = current_user.owned_profiles.find(params[:profile_id])
      @survey_response = @profile.last_survey
    end
    
    def set_question_responses
      unordered_list = @survey_response.question_responses.to_a
      preferred_order = %w{whatlike spend occassion}
      @question_responses = []
      preferred_order.each do|code|
        question_response = unordered_list.detect{|_| _.survey_question.code == code}
        @question_responses << unordered_list.delete(question_response) if question_response.present?
      end
      @question_responses += unordered_list
    end
  end
end

