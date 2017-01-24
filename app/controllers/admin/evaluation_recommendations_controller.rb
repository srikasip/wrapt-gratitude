module Admin
  class EvaluationRecommendationsController < BaseController

    include PjaxModalController

    def show
      @training_set = TrainingSet.find params[:training_set_id] # for breadcrumbs
      @recommendation = EvaluationRecommendation.find params[:id]
      @engine = Recommendations::Engine.new(@training_set, @recommendation.survey_response)
      @engine.generate_recommendations
      @question_ranks = @engine.recommendation_question_ranks(@recommendation)
    end
    
  end
end