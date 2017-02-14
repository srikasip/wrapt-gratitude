module Admin
  class TrainingSetEvaluationsController < BaseController

    before_action :set_training_set

    def show
    end

    private

      def set_training_set
        @training_set = TrainingSet.find params[:training_set_id]
      end
  end
end
