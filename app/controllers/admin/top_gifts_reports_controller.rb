module Admin
  class TopGiftsReportsController < ReportBaseController
    before_filter :load_date_range
    
    def index
      @report = Reports::TopGiftsReport.new(begin_date: @begin_date, end_date: @end_date)
      @report.load_most_recommended_gifts
      @report.load_most_selected_gifts
      @report.preload_gifts
    end
    
    def active_report_nav_section
      'top_gifts_report'
    end

  end
end