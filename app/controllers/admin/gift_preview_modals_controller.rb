module Admin
  class GiftPreviewModalsController < BaseController
    
    include PjaxModalController

    def show
      @gift = Gift.find params[:gift_id]
    end

  end
end