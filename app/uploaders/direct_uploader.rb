# Use this as a base class for uploaders that use Carrierwave::Direct
# to upload directly to S3 from the client
class DirectUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWaveDirect::Uploader
end
