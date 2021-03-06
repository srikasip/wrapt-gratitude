module GiftImages
  class Uploaded < GiftImage
    # This subclass represents images that have been directly
    # uploaded to the gift

    mount_uploader :image, ProductImageUploader

    after_commit :enqueue_processing, if: :key, unless: :image_processed?

    private def enqueue_processing
      DirectUploadedImageProcessingJob.set(wait: 0.second).perform_later(self, key)
    end

    def image_owner
      gift
    end

    def processing_channel_class
      GiftImageProcessingChannel
    end
  end
end
