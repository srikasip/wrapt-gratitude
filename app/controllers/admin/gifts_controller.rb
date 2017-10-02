module Admin
  class GiftsController < BaseController
    before_action :set_gift, only: [:show, :edit, :update, :destroy]

    def index
      @gift_search = GiftSearch.new(gift_search_params)
      @gifts = Gift
        .preload(:primary_gift_image, :gift_images, :product_category, :product_subcategory, {products: [:product_images]}, :tags, :calculated_gift_field)
        .search(gift_search_params)
        .page(params[:page])
        .per(50)
    end

    def show
    end

    def new
      @gift = Gift.new product_category: Gift.default_product_category
      @gift.pretty_parcels.build
      @gift.shipping_parcels.build
    end

    def edit
      @gift.shipping_parcels.empty? and @gift.shipping_parcels.build
      @gift.pretty_parcels.empty? and @gift.pretty_parcels.build
    end

    def create
      @gift = Gift.new(gift_params)
      if @gift.save
        redirect_to admin_gift_products_path(@gift), notice: "#{@gift.title} has been created.  Now add some products."
      else
        render :new
      end
    end

    def update
      if @gift.update(gift_params)
        redirect_to [:admin, @gift], notice: "#{@gift.title} has been updated."
      else
        render :edit
      end
    end

    def destroy
      @gift.destroy
      redirect_to admin_gifts_url(context_params), notice: "#{@gift.title} has been deleted."
    end


    private def set_gift
      @gift = Gift.find(params[:id])
    end

    private def gift_params
      params.require(:gift).permit(:title,
        :description,
        :selling_price,
        :cost,
        :wrapt_sku,
        :available,
        :calculate_cost_from_products,
        :calculate_price_from_products,
        :product_category_id,
        :product_subcategory_id,
        :featured,
        :tag_list,
        :shipping_parcels_attributes => [:id, :parcel_id, :gift_id],
        :gift_parcels_attributes => [:id, :parcel_id, :gift_id]
      )
    end

    def gift_search_params
      params_base = params[:gift_search] || ActionController::Parameters.new
      params_base.permit(:keyword, :product_category_id, :product_subcategory_id, :min_price, :max_price, :tags, :vendor_id, :available)
    end
    helper_method :gift_search_params

    def context_params
      params.permit(:page).merge(gift_search: gift_search_params)
    end
    helper_method :context_params

  end
end
