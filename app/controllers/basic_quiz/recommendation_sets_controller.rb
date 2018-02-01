module BasicQuiz
  class RecommendationSetsController < ApplicationController
    
    helper SurveyQuestionResponsesHelper
    include PjaxModalController
    
    before_filter :load_profile

    def login_required?
      true
    end
    
    def new
      # create a new survey response on the profile
      # and copy the answers from previous survey response
      builder = Recommender::SurveyResponseBuilder.new(@profile)
      if builder.copy_needed?
        @survey_response = builder.copy!
      else
        @survey_response = builder.survey_response
      end
    end
    
    def create
      @survey_response = @profile.last_survey
      if @survey_response.id == params[:survey_response_id].to_i && @survey_response.update_attributes(survey_response_params)
        @profile.update_attribute(:has_viewed_initial_recommendations, append_recommendations?)
        @survey_response.update_attribute(:completed_at, Time.now)
        generate_recommendations
        redirect_to giftee_gift_recommendations_path(@profile)
      else
        flash[:alert] = "Sorry, sometheing went wrong! Please try again!"
        render :new
      end
    end
    
    def load_profile
      @profile = current_user.owned_profiles.find(params[:profile_id])
    end
    
    def append_recommendations?
      recommendation_set = @profile.current_gift_recommendation_set
      return recommendation_set.present? && recommendation_set.generation_number < 1
    end
        
    def generate_recommendations
      job = GenerateRecommendationsJob.new
      job.perform(@profile, survey_response_id: @survey_response.id, append: append_recommendations?)
    end

    def survey_response_params
      params.require(:survey_response).permit(
        question_responses_attributes: [
          :survey_question_option_ids,
          :id,
          :range_response,
          :text_response,
          :other_option_text,
          survey_question_option_ids: []
        ]
      )
    end
      
  end
end

