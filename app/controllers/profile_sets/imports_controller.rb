module ProfileSets
  class ImportsController < ApplicationController

    before_action :set_profile_set, only: [:new, :create]

    def new
      @profile_set_import = ProfileSetImport.new(profile_set: @profile_set)
    end

    def create
      @profile_set_import = ProfileSetImport.new(permitted_params.merge({profile_set: @profile_set}))
      begin
        if @profile_set_import.valid? && @profile_set_import.save_question_responses
          redirect_to @profile_set, notice: 'You imported survey responses into a profile set.'
        else
          render :new
        end
      rescue ProfileSets::Imports::Exceptions::PreloadsNotFound => exception
        @missing_resources_exception = exception
        render :new
      end
    end

    private

    def set_profile_set
      @profile_set = ProfileSet.find params[:profile_set_id]
    end

    def permitted_params
      subparams = params.dig(:profile_set_import)
      if subparams
        subparams.permit(:question_responses_file)
      else
        {}
      end
    end
  end
end
