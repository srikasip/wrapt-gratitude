module Admin
  class SingleProductGiftsController < BaseController
    include PjaxModalController

    helper ::Admin::ProductsIndexContextHelper
    include ProductsIndexContextHelper

    before_action :set_product

    def new
      if @product.single_product_gift.present?
        flash[:alert] = 'Sorry that product already has a single product gift.'
        redirect_to admin_products_path(context_params) #TODO preserve page + search
      else
        @gift = @product.build_single_product_gift
        @gift.pretty_parcels.build
        @gift.shipping_parcels.build
        @sub_categories = []
      end
    end

    def create
      @gift = Gift.new gift_attributes_from_product.merge(gift_params)
      @gift.generate_wrapt_sku
      if @gift.save
        flash[:notice] = "Successfully created a gift from #{@product.title}"
        redirect_to admin_products_path(context_params) #TODO preserve page + search
      else
        flash.now[:alert] = "Sorry, we could not create a single-product gift.  #{@gift.errors.full_messages.join('. ')}"
        @sub_categories = @gift.product_category.children || []
        render :new
      end
    end

    private def set_product
      @product = Product.find params[:product_id]
    end

    private def gift_params
      params.require(:gift).permit(
        :product_category_id,
        :product_subcategory_id,
        :shipping_parcels_attributes => [:id, :parcel_id, :gift_id],
        :pretty_parcels_attributes => [:id, :parcel_id, :gift_id]
      )
    end

    private def gift_attributes_from_product
      {
        title: @product.title,
        description: @product.description,
        available: true,
        products: [@product],
        source_product: @product
      }
    end
  end
end
