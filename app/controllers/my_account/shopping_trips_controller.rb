class MyAccount::ShoppingTripsController < ApplicationController

  # this will be in a modal
  include PjaxModalController

  before_action :load_new_profile

  def new
    @disable_close = true
    # TODO: Do we want to filter out profiles with name 'Unknown'?
    @relationship_profiles = current_user.owned_profiles.where(relationship: @new_profile.relationship)
  end

  def create
    @old_profile = Profile.find(params[:shopping_trip][:profile_id])
    @new_profile.destroy
    # TODO: Load in modal
    redirect_to giftee_survey_response_copy_path(@old_profile, @old_profile.survey_responses.last)
  end

  private

  def load_new_profile
    @new_profile = current_user.owned_profiles.last
  end

end