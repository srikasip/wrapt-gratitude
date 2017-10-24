require 'fileutils'

module Admin
  class ProductsExportsController < BaseController
    def create
      ProductsExportJob.perform_later(permitted_params)

      if request.xhr?
        head :ok
      else
        redirect_back fallback_location: admin_products_path
      end
    end

    private def permitted_params
      params.permit.to_hash.merge('user_id' => current_user.id)
    end
  end
end
