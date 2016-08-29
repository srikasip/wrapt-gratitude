class RangeImpactCorrelationSwitchingsController < ApplicationController
  before_action :set_training_set
  before_action :set_training_set_product_question


  def create
    RangeImpactCorrelationSwitching.new(@training_set_product_question).save
    redirect_to edit_training_set_product_question_impact_path(@training_set, @training_set_product_question)
  end

  private 
    def set_training_set
      @training_set = TrainingSet.find params[:training_set_id]
    end

    def set_training_set_product_question
      @training_set_product_question = @training_set.product_questions.find(params[:product_question_impact_id])
    end

end
