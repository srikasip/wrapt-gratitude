# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ProductImageProcessingChannel < ApplicationCable::Channel
  def subscribed
    product = Product.find params[:product_id]
    stream_for product
  end

  def unsubscribed
    stop_all_streams
  end
end
