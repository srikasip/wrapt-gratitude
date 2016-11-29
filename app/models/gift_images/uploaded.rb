module GiftImages
  class Uploaded < GiftImage
    # This subclass represents images that have been directly
    # uploaded to the gift

    mount_uploader :image, ProductImageUploader

    after_save :enqueue_processing, if: :key, unless: :image_processed?

    private def enqueue_processing
      DirectUploadedImageProcessingJob.perform_later(self, key)
    end

    def image_owner
      gift
    end

    def processing_channel_class
      GiftImageProcessingChannel
    end

    def to_partial_path
      'gift_images/gift_images_uploaded'
    end

  end
end