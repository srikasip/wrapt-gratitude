module Admin
  class ReportsController < ReportBaseController
    helper :gift_recommendations

    before_filter :load_date_range

    def index
      if @weeks_ago == -1 && params[:giftee_id].to_i > 0
        @begin_date = Time.parse('2016-05-05')
        @end_date = Time.now+2.minutes
      end

      if @weeks_ago == -1 && params[:giftee_id].blank?
        flash.now[:alert] = "You cannot view all the data without a giftee."
      end

      @report = Reports::ProfileEventReport.new(begin_date: @begin_date, end_date: @end_date, giftee_id: params[:giftee_id])
      @report.load_events
      @report.generate_stats
      @report.preload_models

      @summary = @report.summary_report
    end

    def active_report_nav_section
      'activity_report'
    end
  end
end
