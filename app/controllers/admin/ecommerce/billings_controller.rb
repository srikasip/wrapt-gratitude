module Admin
  module Ecommerce
    class BillingsController < BaseController
      def index
        params[:search] ||= {}
        params[:search][:status] ||= {}
        @billing_report = BillingReport.new(params)
        respond_to do |x|
          x.html { @billing_report.paginated_results }
          x.csv { @billing_report.csv_results }
        end
      end
    end
  end
end
