module Admin
  class EvaluationRecommendationsController < BaseController

    layout 'xhr'

    def show
      @training_set = TrainingSet.find(params[:training_set_id])
      @survey_response = ProfileSetSurveyResponse.find(params[:id])
      @engine = Recommendations::Engine.new(@training_set, @survey_response)
      @recommendations = @engine.generate_recommendations
    end
    
  end
end