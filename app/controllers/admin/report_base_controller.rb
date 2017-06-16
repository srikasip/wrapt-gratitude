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
  end
end