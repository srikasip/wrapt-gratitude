
module Admin
  class TrainingSetQuestionsController < BaseController
    # Ajax controller that drives the question display on TrainingSets#index
    # for Product-Question Crud see ProductQuestionImpactsController

    def index
      @training_set = TrainingSet.find params[:training_set_id]
      @gift = Gift.find params[:gift_id]
      @gift_question_impacts = @training_set.gift_question_impacts.
        preload(:survey_question).
        joins(:survey_question).
        where(gift_id: @gift.id).
        order(question_impact: :desc).
        order('survey_questions.sort_order')

      render layout: 'xhr'
    end

  end
end