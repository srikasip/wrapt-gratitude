module Admin
  class SurveyResponseTraitEvaluationsController < BaseController
    before_action :set_trait_training_set

    helper TraitTrainingSetsSectionHelper

    def index
      @profile_sets = @trait_training_set.survey.profile_sets
    end

    def show
      @profile_sets = @trait_training_set.survey.profile_sets
      @survey_response = ProfileSetSurveyResponse.find params[:id]
      @evaluation = @trait_training_set.evaluations.where(response: @survey_response).first_or_initialize
      matches_need_refresh = @evaluation.new_record? || @evaluation.stale?
      @evaluation.save if @evaluation.new_record?
      if matches_need_refresh
        @evaluation.update_attribute :matching_in_progress, true
        GenerateTraitEvaluationTagMatchesJob.perform_later(@evaluation)
      end
    end

    private def set_trait_training_set
      @trait_training_set = TraitTrainingSet.find params[:trait_training_set_id]
    end
    

  end
end