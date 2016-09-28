class DirectUploadedImageProcessingJob < ApplicationJob
  # works with anything that has a Carrierwave::Direct uploader
  # mounted as 'image' that also has an 'image_processed' boolean

  queue_as :default

  def perform image_owner, key
    image_owner.key = key
    image_owner.remote_image_url = image_owner.image.direct_fog_url(with_path: true)
    image_owner.image_processed = true
    image_owner.save!
  end

end