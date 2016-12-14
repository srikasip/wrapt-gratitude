module Admin
  class TrainingSetExportsController < BaseController
    
    def show
      @training_set = TrainingSet.find params[:training_set_id]
      
      # generate the export file
      export_file_path = TrainingSetExport.new(training_set: @training_set).generate_file!

      # send it
      send_file export_file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

      # schedule the file for cleanup
      CleanupExportTempfileJob.set(wait: 30.minutes).perform_later(export_file_path)
    end

  end
end