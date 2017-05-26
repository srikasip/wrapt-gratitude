module Admin

  class GiftTagImportsController < BaseController

    def new
      @errors = []
    end

    def create
      @job = GiftTagFileImportJob.new
      if @job.perform(params[:import_file])
        redirect_to admin_gifts_path, notice: 'The gift tags have been imported.'
      else
        @errors = @job.errors
        render :new
      end
    end
  end
end