# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GiftImageProcessingChannel < ApplicationCable::Channel
  def subscribed
    gift = Gift.find params[:gift_id]
    stream_for gift
  end

  def unsubscribed
    stop_all_streams
  end
end
