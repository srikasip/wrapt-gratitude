module Admin
  module Ecommerce
    class DashboardController < BaseController
      before_action { @active_top_nav_section = 'ecommerce' }

      def index
      end
    end
  end
end
