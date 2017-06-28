module Admin
  class ReportsController < ReportBaseController
    helper :gift_recommendations
    
    before_filter :load_date_range
    
    def index
      @report = Reports::ProfileEventReport.new(begin_date: @begin_date, end_date: @end_date)
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
