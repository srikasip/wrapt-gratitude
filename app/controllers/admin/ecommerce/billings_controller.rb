module Admin
  module Ecommerce
    class BillingsController < BaseController
      def index
        params[:search] ||= {}
        params[:search][:status] ||= {}
        params[:search][:date_range_start] ||= (Date.today-1.week).to_s
        params[:search][:date_range_end] ||= Date.today.to_s

        @billing_report = Ec::BillingReport.new(params)

        if params['content_type'] == 'csv'
          if @billing_report.has_vendor?
            send_data @billing_report.csv_results, filename: @billing_report.csv_filename
          else
            send_data "error\nno data unless you have a vendor specified", filename: 'nodata.csv'
          end
        else
          @purchase_orders = @billing_report.paginated_results
        end
      end
    end
  end
end
