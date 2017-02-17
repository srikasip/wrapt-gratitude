module Admin
  module ProfileSets
    class ImportsController < BaseController

      before_action :load_profile_set, only: [:new, :create]

      def new
        @errors = []
      end

      def create
        @profile_set_import = ProfileSetImport.new(@profile_set, params[:import_file])
        if @profile_set_import.open_file
          ProfileSet.transaction do
            @profile_set_import.truncate_data
            @profile_set_import.insert_data
          end
        end
        if @profile_set_import.errors.none?
          redirect_to [:admin, @profile_set], notice: 'All of your responses have been imported into the profile set.'
        else
          @errors = @profile_set_import.errors
          render :new
        end
      end

      private

      def load_profile_set
        @profile_set = ProfileSet.find params[:profile_set_id]
      end
    end
  end
end