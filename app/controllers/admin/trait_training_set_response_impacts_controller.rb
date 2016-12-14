module Admin
  class TraitTrainingSetResponseImpactsController < BaseController
    # Ajax controller for loading the reseponse impact fields for TraitTrainingSetQuestions#show

    def index
      @trait_training_set = TraitTrainingSet.find params[:trait_training_set_id]
      @trait_training_set_question = @trait_training_set.trait_training_set_questions.find params[:question_id]
      if params[:facet_id].present?
        facet = ProfileTraits::Facet.find params[:facet_id]
      else
        facet = @trait_training_set_question.facet
      end
      render partial: 'index', locals: {facet: facet}
    end

  end
end