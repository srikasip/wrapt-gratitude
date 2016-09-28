# Base stuff common to all or at least most uploaded files
class ApplicationUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  # storage(Rails.env.production? ? :fog : :file)
  include CarrierWaveDirect::Uploader

  include CarrierWave::MimeTypes
  process :set_content_type

  # def store_dir
  #   if Rails.env.production?
  #     "uploads/#{model.class.to_s.underscore}/#{mounted_as}/"
  #   else
  #     "development-#{`whoami`.chomp}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/"
  #   end
  # end

end
