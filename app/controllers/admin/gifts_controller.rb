module Admin
  class GiftsController < BaseController
    before_action :set_gift, only: [:show, :edit, :update, :destroy, :add_to_recommendations]

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
      _initialize_variables
    end

    def edit
      _initialize_variables
    end

    def create
      @gift = Gift.new(gift_params)
      if @gift.save
        redirect_to admin_gift_products_path(@gift), notice: "#{@gift.title} has been created.  Now add some products."
      else
        @error_message = @gift.errors.full_messages.join('. ')
        _initialize_variables
        render :new
      end
    end

    def update
      if @gift.update(gift_params)
        redirect_to [:admin, @gift], notice: "#{@gift.title} has been updated."
      else
        _initialize_variables
        @error_message = @gift.errors.full_messages.join('. ')
        render :edit
      end
    end

    def add_to_recommendations
      good_params = params.require(:gift_recommendation).permit(:profile_id, :user_id)

      user = User.find(good_params[:user_id])
      giftee = user.owned_profiles.find(good_params[:profile_id])

      recommendation = giftee.gift_recommendations.where(gift: @gift, profile: giftee).first_or_initialize
      recommendation.position = -1
      recommendation.save!

      flash[:notice] = 'The gift was added to their recommendations'
      redirect_back(fallback_location: admin_gift_path(id: @gift.id))
    end

    def destroy
      @gift.destroy
      redirect_to admin_gifts_url(context_params), notice: "#{@gift.title} has been deleted."
    end

    private

    private def set_gift
      @gift = Gift.find(params[:id])
    end

    private def gift_params
      params.require(:gift).permit(:title,
        :description,
        :selling_price,
        :cost,
        :weight_in_pounds,
        :wrapt_sku,
        :available,
        :tax_code_id,
        :calculate_cost_from_products,
        :calculate_price_from_products,
        :calculate_weight_from_products,
        :product_category_id,
        :product_subcategory_id,
        :featured,
        :tag_list,
        :insurance_in_dollars,
        :shipping_parcels_attributes => [:id, :parcel_id, :gift_id],
        :pretty_parcels_attributes => [:id, :parcel_id, :gift_id]
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

    def _initialize_variables
      @gift.shipping_parcels.empty? and @gift.shipping_parcels.build
      @gift.pretty_parcels.empty? and @gift.pretty_parcels.build

      @tax_codes = Ec::Tax::Code.active.all
    end
  end
end
