module Admin
  class ReportBaseController < BaseController
    
    def active_top_nav_section
      'reports'
    end
    helper_method :active_top_nav_section
    
    def active_report_nav_section
      ''
    end
    helper_method :active_report_nav_section

    def load_date_range
      @weeks_ago = params[:weeks_ago].to_i
      @begin_date = @weeks_ago.weeks.ago.beginning_of_week
      @end_date = @weeks_ago.weeks.ago.end_of_week
    end

  end
end