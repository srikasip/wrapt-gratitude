class TraitTrainingSetQuestionsController < ApplicationController
  before_action :set_trait_training_set

  def index
    @trait_training_set.refresh_questions!
    @trait_training_set_questions = @trait_training_set.trait_training_set_questions    
  end

  private def set_trait_training_set
    @trait_training_set = TraitTrainingSet.find params[:trait_training_set_id]
  end
  
end