module Admin
  module TrainingSets
    class ImportsController < BaseController

      before_action :load_training_set, only: [:new, :create]

      def new
        @errors = []
      end

      def create
        @training_set_import = TrainingSetImport.new(@training_set, params[:import_file])
        @training_set_import.open_file
        TrainingSet.transaction do
          @training_set_import.truncate_data
          @training_set_import.insert_data
        end
        if @training_set_import.errors.none?
          redirect_to [:admin, @training_set], notice: 'You imported impacts into a training set.'
        else
          @errors = @training_set_import.errors
          render :new
        end
      end

      private

      def load_training_set
        @training_set = TrainingSet.find params[:training_set_id]
      end

    end
  end
end