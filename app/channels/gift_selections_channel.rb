# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GiftSelectionsChannel < ApplicationCable::Channel
  def subscribed
    # profile = current_user.owned_profiles.find params[:profile_id]
    profile = Profile.find params[:profile_id]
    stream_for profile
  end

  def unsubscribed
    stop_all_streams
  end
end
