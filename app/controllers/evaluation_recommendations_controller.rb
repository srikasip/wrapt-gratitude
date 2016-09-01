class EvaluationRecommendationsController < ApplicationController


  def show
    @training_set = TrainingSet.find params[:training_set_id] # for breadcrumbs
    @recommendation = EvaluationRecommendation.find params[:id]
  end
  
end