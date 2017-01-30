class ProfileCheckoutsController < ApplicationController

  def create
    flash.notice = 'Gift Selection Notification coming in a future Release'
    redirect_to root_path
  end
  
end