class HomePagesController < ApplicationController
  skip_before_filter :require_admin!

  def show
  end
end
