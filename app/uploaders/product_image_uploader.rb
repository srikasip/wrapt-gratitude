class ProductImageUploader < ApplicationUploader

  include CarrierWaveDirect::Uploader

  version :small do
    process :resize_to_fit => [240, 240]
  end
  version :large do
    process :resize_to_fit => [640, 640]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
