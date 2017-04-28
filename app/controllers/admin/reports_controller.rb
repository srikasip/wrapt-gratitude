module Admin
  class ReportsController < BaseController
    helper :gift_recommendations
    
    def index
      @weeks_ago = params[:weeks_ago].to_i
      @begin_date = @weeks_ago.weeks.ago.beginning_of_week
      @end_date = @weeks_ago.weeks.ago.end_of_week
      @report = Reports::ProfileEventReport.new(begin_date: @begin_date, end_date: @end_date)
      @report.load_events
      @report.generate_stats
      @report.preload_models
      
      @summary = @report.summary_report
    end
  end
end
