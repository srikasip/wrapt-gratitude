module Admin
  module Ecommerce
    class DashboardController < BaseController
      before_action { @active_top_nav_section = 'ecommerce' }

      def index
      end

      def stats
        @vendors = Vendor.all
        @gifts = Gift.available.preload(:calculated_gift_field).all
        @products = Product.preload(:product_category).all
      end
    end
  end
end
