module Admin
  class GiftPreviewsController < BaseController

    layout 'admin_public_previews'
    helper CarouselHelper
    
    def show
      @gift = Gift.find params[:gift_id]
    end

  end
end