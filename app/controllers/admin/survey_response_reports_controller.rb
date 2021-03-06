module Admin
  class SurveyResponseReportsController < ReportBaseController
    before_filter :load_date_range
    
    def index
      @report = Reports::SurveyResponseReport.new(begin_date: @begin_date, end_date: @end_date)
      @report.load_survey_response_stats
      @report.load_choice_response_stats
      @report.preload_surveys
    end
    
    
    def active_report_nav_section
      'survey_response_report'
    end
  end
end