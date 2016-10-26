class DirectUploadedImageProcessingJob < ApplicationJob
  # works with anything that has a Carrierwave::Direct uploader
  # mounted as 'image' that also has an 'image_processed' boolean

  queue_as :default

  def perform image_record, key
    image_record.key = key
    image_record.remote_image_url = image_record.image.direct_fog_url(with_path: true)
    image_record.image_processed = true
    image_record.save!
    # TODO make type agnostic
    image_record.processing_channel_class.broadcast_to image_record.image_owner, html: render_product_image(image_record), image_record_id: image_record.id
  end

  private def render_product_image image_record
    ApplicationController.renderer.render image_record
  end
  

end