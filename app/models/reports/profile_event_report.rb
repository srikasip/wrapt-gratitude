module Reports
  class ProfileEventReport
    attr_reader :begin_date, :end_date
    
    def initialize(params)
      @begin_date = params[:begin_date]
      @end_date = params[:end_date]
    end
    
    def profile_ids
      @_profile_ids || load_profile_ids
    end
    
    def profiles
      @_profiles || load_profiles
    end
    
    def created_profiles
      @_created_profiles || load_created_profiles
    end
    
    def profile_created?(profile)
      profiles_created.include?(profile)
    end
    
    def profile_questions
      @_profile_questions || load_profile_questions
    end
    
    def completed_surveys
      @_completed_surveys || load_completed_surveys
    end
    
    def load_profiles
      @_profiles = {}
      Profile.preload(:owner).where(id: profile_ids).each do |profile|
        @_profiles[profile.id] = profile
      end
      @_profiles
    end
    
    def load_profile_ids
      (created_profiles.keys + profile_questions.keys + completed_surveys.keys).uniq
    end
    
    def load_created_profiles
      @_created_profiles = {}
      sql = %{select id, created_at from profiles where created_at #{date_range_sql}}
      Profile.connection.select_rows(sql).each do |row|
        @_created_profiles[row[0].to_i] = {ts: row[1].to_time}
      end
      @_created_profiles
    end
    
    def load_profile_questions
      @_profile_questions = {}
      sql = %{
        select profile_id, survey_question_id, ts
        from (
          select sr.profile_id, sqr.survey_question_id, sqr.answered_at as ts,
          row_number() over (partition by sr.profile_id order by sqr.answered_at desc) as rn
          from survey_question_responses as sqr
          join survey_responses as sr on sqr.survey_response_id = sr.id
          where sqr.answered_at #{date_range_sql}
        ) as t
        where rn = 1
      }
      Profile.connection.select_rows(sql).each do |row|
        @_profile_questions[row[0].to_i] = {ts: row[2].to_time, last_question_id: row[1].to_i}
      end
      @_profile_questions
    end
  
  
    def load_completed_surveys
      @_completed_surveys = {}
      sql = %{select profile_id, completed_at from survey_responses where completed_at #{date_range_sql}}
      Profile.connection.select_rows(sql).each do |row|
        @_completed_surveys[row[0].to_i] = {ts: row[1].to_time}
      end
      @_completed_surveys
    end
    
    protected
    
    def date_range_sql
      "between '#{Profile.connection.quoted_date(begin_date)}' and '#{Profile.connection.quoted_date(end_date)}'"
    end
    
  end
end

