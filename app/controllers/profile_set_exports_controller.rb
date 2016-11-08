class ProfileSetExportsController < ApplicationController
  before_action :set_profile_set

  def create
    target_file_path = Rails.root.join "tmp", profile_set_export_filename
    ProfileSetFileExportJob.new.perform(@profile_set, target_file_path.to_s)
    send_file target_file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  private def set_profile_set
    @profile_set = ProfileSet.find params[:profile_set_id]
  end

  private def profile_set_export_filename
    "wrapt_response_set_#{@profile_set.name.underscore}_#{Time.now.strftime('%Y-%m-%d-%H%M%S%L')}.xlsx"
  end
  
  
end