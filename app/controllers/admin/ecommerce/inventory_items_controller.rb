module Admin
  module Ecommerce
    class InventoryItemsController < BaseController
      before_action { @active_top_nav_section = 'ecommerce' }

      include PjaxModalController

      def index
        _load_products
        @errors = []
      end

      def upload_form
      end

      def upload
        @job = InventoryImportJob.new
        if @job.perform(params[:import_file])
          redirect_to admin_ecommerce_inventory_items_path, notice: 'Inventory has been updated.'
        else
          @errors = @job.errors
          _load_products
          render :index
        end
      end

      def download
        Tempfile.open('export.xlsx') do |tempfile|
          @job = InventoryExportJob.new
          @job.perform(tempfile.path)
          tempfile.rewind
          now = Time.zone.now.strftime('%Y.%m.%d')
          send_file(tempfile.path, content_type: 'application/vnd.ms-excel', filename: "inventory-export-#{now}.xlsx")
        end
      end

      private

      def _load_products
        @products = Product.order('wrapt_sku').page(params[:page])
      end
    end
  end
end
