# Ajax controller that drives the question display on TrainingSets#index
# for Product-Question Crud see TrainingSetProductQuestionsController
class TrainingSetQuestionsController < ApplicationController
  
  def index
    @training_set = TrainingSet.find params[:training_set_id]
    @product = Product.find params[:product_id]
    @product_questions = @training_set.product_questions.where(product_id: @product.id).order(:created_at)
    render layout: 'xhr'
  end

end