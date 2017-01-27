class GiftImageUploader < DirectUploader

  version :small do
    process :resize_to_fit => [480, 480]
  end
  version :large do
    process :resize_to_fit => [1280, 1280]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
