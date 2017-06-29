module Reports
  class SurveyResponseReport
    attr_reader :begin_date, :end_date
    
    def initialize(params)
      @begin_date = params[:begin_date]
      @end_date = params[:end_date]
    end
            
    def profile_id_sql
      Profile.where(owner_id: User.external).where(created_at: [begin_date..end_date]).select(:id).to_sql
    end
    
  end
end

