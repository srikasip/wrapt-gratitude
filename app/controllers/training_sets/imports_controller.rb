module TrainingSets
  class ImportsController < ApplicationController

    before_action :set_training_set, only: [:new, :create]

    def new
      @training_set_import = TrainingSetImport.new(training_set: @training_set)
    end

    def create
      @training_set_import = TrainingSetImport.new(permitted_params.merge({training_set: @training_set}))
      if @training_set_import.valid?
        redirect_to @training_set, notice: 'You imported impacts into a training set.'
      else
        render :new
      end
    end

    private

    def set_training_set
      @training_set = TrainingSet.find params[:training_set_id]
    end

    def permitted_params
      subparams = params.dig(:training_set_import)
      if subparams
        subparams.permit(:records_file)
      else
        {}
      end
    end
  end
end
