module Admin
  class PublicSurveyExportsController < ApplicationController
    
    def create
      FileUtils.mkdir_p Rails.root.join("tmp", "public_survey_exports")
      target_file_path = Rails.root.join("tmp", "public_survey_exports", export_filename).to_s
      PublicSurveysFileExportJob.new.perform(SurveyResponse.completed, target_file_path)
      send_file target_file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      CleanupExportTempfileJob.set(wait: 30.minutes).perform_later(target_file_path)
    end

    private def export_filename
      "wrapt_public_quizzes_#{Time.now.strftime('%Y-%m-%d-%H%M%S%L')}.xlsx"
    end


  end
end