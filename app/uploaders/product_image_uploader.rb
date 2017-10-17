class ProductImageUploader < DirectUploader
  version :small do
    process :resize_to_fit => [480, 480]
  end
  version :large do
    process :resize_to_fit => [1280, 1280]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  fog_public true

  process :store_dimensions
  private def store_dimensions
    if file && model
      model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
  end
end
