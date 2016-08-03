class HomePagesController < ApplicationController

  def show
  end

  # skip_before_filter wasn't working for some reason
  def require_admin!
    true
  end
end
