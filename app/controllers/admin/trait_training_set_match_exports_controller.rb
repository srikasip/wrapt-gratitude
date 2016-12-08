module Admin
  class TraitTrainingSetMatchExportsController < BaseController
    
    def show
      @trait_training_set = TraitTrainingSet.find params[:trait_training_set_id]
      @profile_set = @trait_training_set.survey.profile_sets.find params[:id]
      
      # generate the export file
      export_file_path = TraitTrainingSetMatchExport.new(trait_training_set: @trait_training_set, profile_set: @profile_set).generate_file!

      # send it
      send_file export_file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

      # schedule the file for cleanup
      CleanupExportTempfileJob.set(wait: 30.minutes).perform_later(export_file_path)
    end

  end
end