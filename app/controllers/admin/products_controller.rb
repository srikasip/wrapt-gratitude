module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [:show, :edit, :update, :destroy]

    helper ::Admin::ProductsIndexContextHelper
    include ProductsIndexContextHelper

    # GET /products
    # GET /products.json
    def index
      @product_search = ProductSearch.new(product_search_params)
      @products = Product
        .preload(:product_category, :product_subcategory)
        .search(product_search_params)
        .page(params[:page])
        .per(50)
    end

    # GET /products/1
    # GET /products/1.json
    def show
    end

    # GET /products/new
    def new
      @product = Product.new
    end

    # GET /products/1/edit
    def edit
    end

    # POST /products
    # POST /products.json
    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_product_images_path(@product), notice: "Created #{@product.title}.  Now add some images."
      else
        render :new
      end
    end

    # PATCH/PUT /products/1
    # PATCH/PUT /products/1.json
    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: 'Product was successfully updated.'
      else
        #flash.now[:alert] = "#{@product.errors.full_messages.join('. ')}"
        render :edit
      end
    end

    # DELETE /products/1
    # DELETE /products/1.json
    def destroy
      @product.destroy
      redirect_to admin_products_url(context_params), notice: 'Product was successfully deleted.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_product
        @product = Product.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def product_params
        params.require(:product).permit(
          :title,
          :description,
          :price,
          :wrapt_sku,
          :vendor_sku,
          :public,
          :image,
          :remove_image,
          :vendor_retail_price,
          :wrapt_cost,
          :weight_in_pounds,
          :units_available,
          :vendor_id,
          :source_vendor_id,
          :notes,
          :product_category_id,
          :product_subcategory_id
        )
      end

  end
end
