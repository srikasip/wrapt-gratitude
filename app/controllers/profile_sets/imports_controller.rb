module ProfileSets
  class ImportsController < ApplicationController

    before_action :set_profile_set, only: [:new, :create]

    def new
      @profile_set_import = ProfileSetImport.new(profile_set: @profile_set)
    end

    def create
      @profile_set_import = ProfileSetImport.new(permitted_params.merge({profile_set: @profile_set}))
      begin
        @profile_set_import.valid? && @profile_set_import.save_question_responses
        redirect_to @profile_set, notice: 'You imported survey responses into a profile set.'
      rescue ProfileSets::Imports::Exceptions::PreloadsNotFound => exception
        flash.now[:alert] = "There was a problem with your upload. The following #{exception.sheet_column_name.to_s.pluralize} could not be found: #{exception.lookups.join(', ')}"
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
