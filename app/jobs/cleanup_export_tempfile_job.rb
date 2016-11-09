require 'fileutils'
class CleanupExportTempfileJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    if File.file? file_path
      FileUtils.rm file_path
    end
  end
end
