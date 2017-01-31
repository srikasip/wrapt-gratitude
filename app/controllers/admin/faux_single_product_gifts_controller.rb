module Admin
  class FauxSingleProductGiftsController < BaseController

    def index
      @gifts = Gift
        .where(source_product_id: nil)
        .preload(gift_products: {product: :single_product_gift})
        .to_a
        .select { |gift| gift.gift_products.size == 1 }
    end

    def update
      # Convert to a single product gift
      @gift = Gift.find params[:id]
      source_product_id = @gift.product_ids&.first
      if source_product_id.present? && @gift.duplicate_single_product_gift.blank?
        @gift.update_attribute :source_product_id, source_product_id
        flash.notice = "Converted #{@gift.title} to a Single Product Gift"
      else
        flash.alert = 'Sorry, we were unable to convert that gift'
      end
      redirect_to admin_faux_single_product_gifts_path
    end

    def active_top_nav_section
      "gifts"
    end
    helper_method :active_top_nav_section

  end
end