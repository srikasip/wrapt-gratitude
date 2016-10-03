# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ProductImageProcessingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "product_image_processing"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
