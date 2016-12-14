module Admin
  class TraitTrainingSetQuestionsController < BaseController
    before_action :set_trait_training_set
    before_action :set_trait_training_set_question, except: :index

    helper ::Admin::TraitTrainingSetResponseImpactsHelper
    helper ::Admin::TraitTrainingSetsSectionHelper

    def index
      @trait_training_set.refresh_questions!
      @trait_training_set_questions = @trait_training_set.trait_training_set_questions    
    end

    def edit
    end

    def update
      if @trait_training_set_question.update trait_training_set_question_params
        flash[:notice] = "Response Impacts were successfuly updated"
        redirect_to admin_trait_training_set_questions_path(@trait_training_set)
      else
        flash[:error] = "Please correct the errors below."
        render :edit
      end
    end

    private def set_trait_training_set
      @trait_training_set = TraitTrainingSet.find params[:trait_training_set_id]
    end

    private def set_trait_training_set_question
      @trait_training_set_question = @trait_training_set.trait_training_set_questions.find params[:id]
    end

    private def trait_training_set_question_params
      params.require(:trait_training_set_question).permit(
        :facet_id,
        trait_response_impacts_attributes: [:id, :_destroy, :survey_question_option_id, :profile_traits_tag_id, :range_position]
      )
    end
    
    
    
  end
end