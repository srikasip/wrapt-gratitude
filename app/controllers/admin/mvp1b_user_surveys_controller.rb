module Admin
  class Mvp1bUserSurveysController < ReportBaseController
    def index
      @surveys = Mvp1bUserSurvey.
        where('created_at > ?', Date.new(2017, 6, 11)).
        where(user_id: User.external).
        order(created_at: :desc)
      @summary_report = Reports::Mvp1bUserSurveySummaryReport.new(@surveys)
      @summary_report.load_stats
    end
    
    def active_report_nav_section
      'mvp1b_survey_report'
    end
  end
end