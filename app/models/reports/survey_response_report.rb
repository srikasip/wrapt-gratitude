module Reports
  class SurveyResponseReport
    attr_reader :begin_date, :end_date,
      :choice_response_stats, :preloaded_surveys, :survey_response_stats
    
    def initialize(params)
      @begin_date = params[:begin_date]
      @end_date = params[:end_date]
      @choice_response_stats = []
      @survey_response_stats = []
      @preloaded_surveys = []
    end

    def load_survey_response_stats
      sql = %{
        select survey_id, count(id) as response_count
        from survey_responses
        where
          profile_id in (#{profile_id_sql}) and
          completed_at is not null
        group by survey_id
      }
      @survey_response_stats = SurveyResponse.connection.select_all(sql).to_hash
    end
    
    def load_choice_response_stats
      sql = %{
        select
          sr.survey_id,
          sqr.survey_question_id,
          sqro.survey_question_option_id,
          count(sqro.id) as option_count
        from survey_responses as sr
        join survey_question_responses as sqr on sr.id = sqr.survey_response_id
        join survey_questions as sq on sq.id = sqr.survey_question_id
        join survey_question_response_options as sqro on sqro.survey_question_response_id = sqr.id
        where
          sr.profile_id in (#{profile_id_sql}) and
          sq.type = 'SurveyQuestions::MultipleChoice' and
          sr.completed_at is not null
        group by
          sr.survey_id,
          sqr.survey_question_id,
          sqro.survey_question_option_id
      }
      @choice_response_stats = SurveyResponse.connection.select_all(sql).to_hash
    end
    
    def preload_surveys
      survey_ids = (@choice_response_stats + @survey_response_stats).map{|s| s['survey_id']}.uniq
      @preloaded_surveys = Survey.preload(questions: [:options]).
        where(id: survey_ids).index_by(&:id)
    end
    
    def profile_id_sql
      Profile.where(owner_id: User.external).where(created_at: [begin_date..end_date]).select(:id).to_sql
    end
    
  end
end

