module Admin
  class GiftImageOrderingsController < SortableListOrderingsController

    def sortables
      gift = Gift.find params[:gift_id]
      return gift.gift_images
    end

  end
end