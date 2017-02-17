# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RecipientGiftSelectionsChannel < PublicAccessCable::Channel
  def subscribed
    if profile = Profile.find_by_recipient_access_token(params[:profile_id])
      stream_for profile
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
