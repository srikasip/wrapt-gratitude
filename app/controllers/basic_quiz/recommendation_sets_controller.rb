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
      @survey_response = builder.copy!
    end
    
    def create
      @survey_response = @profile.last_survey
      if @survey_response.id == params[:survey_response_id].to_i && @survey_response.update_attributes(survey_response_params)
        @profile.has_viewed_initial_recommendations = true
        @profile.save
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
        
    def generate_recommendations
      recommendation_set = @profile.current_gift_recommendation_set
      append = recommendation_set.present? && recommendation_set.generation_number < 1
      job = GenerateRecommendationsJob.new
      job.perform(@profile, survey_response_id: @survey_response.id, append: append)
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

