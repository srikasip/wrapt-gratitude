class ProductImageProcessingJob < ApplicationJob
  queue_as :default

  def perform product_image, key
    product_image.key = key
    product_image.remote_image_url = product_image.image.direct_fog_url(with_path: true)
    product_image.image_processed = true
    result = product_image.save!
    Rails.logger.debug '%%%%%%%%%%%%%%%%%%%%%'
    Rails.logger.debug product_image.key
    Rails.logger.debug result
    Rails.logger.debug product_image.remote_image_url
  end

end