# Base stuff common to all or at least most uploaded files
class ApplicationUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :fog

  include CarrierWave::MimeTypes
  process :set_content_type

  def store_dir
    if Rails.env.production? || Rails.env.staging?
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    else
      "development-#{`whoami`.chomp}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end

end
