module BasicQuiz
  class RecommendationSetsController < ApplicationController
    
    helper SurveyQuestionResponsesHelper
    include PjaxModalController
    
    before_filter :load_profile
    
    def new
      builder = Recommender::SurveyResponseBuilder.new(@profile)
      @survey_response = builder.copy!
    end
    
    def create
      @survey_response = @profile.last_survey
      if @survey_response.update_attributes(survey_response_params)
        @profile.has_viewed_initial_recommendations = true
        @profile.save
        generate_recommendations
        redirect_to giftee_gift_recommendations_path(@profile)
      else
        flash[:alert] = "Sorry, sometheing went wrong! Please try again!"
        render :new
      end
    end
    
    def load_profile(args)
      @profile = current_user.owned_profiles.find(params[:profile_id])
    end
    
    def generate_recommendations
      recommendation_set = @profile.current_gift_recommendation_set
      append = recommendation_set.present? && recommendation_set.generation_number < 1
      job = GenerateRecommendationsJob.new
      job.perform(@profile, survey_response_id: @survey_response.id, append: append)
    end
    
  end
end

