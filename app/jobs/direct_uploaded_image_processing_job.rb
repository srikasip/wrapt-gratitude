class DirectUploadedImageProcessingJob < ApplicationJob
  # works with anything that has a Carrierwave::Direct uploader
  # mounted as 'image' that also has an 'image_processed' boolean

  queue_as :default

  def perform image_owner, key
    image_owner.key = key
    image_owner.remote_image_url = image_owner.image.direct_fog_url(with_path: true)
    image_owner.image_processed = true
    image_owner.save!
    # TODO make type agnostic
    puts ">>>>>>>>>> Sending on product_image_processing_#{image_owner.product.id}"
    ActionCable.server.broadcast "product_image_processing_#{image_owner.product.id}", html: render_product_image(image_owner), product_image_id: image_owner.id
  end

  private def render_product_image image_owner
    ApplicationController.renderer.render partial: 'product_images/product_image', locals: {product_image: image_owner}
  end
  

end