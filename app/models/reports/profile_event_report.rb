module Reports
  class ProfileEventReport
    attr_reader :begin_date, :end_date,
      :preloaded_questions, :preloaded_profiles, :preloaded_gifts,
      :sorted_profile_ids, :events, :stats
    
    def initialize(params)
      @begin_date = params[:begin_date]
      @end_date = params[:end_date]
      @preloaded_questions = {}
      @preloaded_profiles = {}
      @preloaded_gifts = {}
      @sorted_profile_ids = []
      @events = {}
      @stats = {}
    end
    
    def load_events
      @events = {}
      
      load_profile_created_events
      load_question_answered_events
      load_survey_completed_events
      load_gift_selected_events
      load_gift_liked_events
      load_gift_disliked_events
      load_recipient_invited_events
      
      sort_events
      sort_profile_ids
    end
    
    def generate_stats
      @stats = {
        profiles_created: {count: 0},
        surveys_completed: {count: 0},
        gifts_selected: {count: 0},
        gifts_liked: {count: 0},
        gifts_disliked: {count: 0},
        recipients_invited: {count: 0}
      }
      events.values.flatten.each do |event|
        case event[:type]
        when 'profile_created'
          @stats[:profiles_created][:count] += 1
        when 'survey_completed'
          @stats[:surveys_completed][:count] += 1
        when 'gift_selected'
          @stats[:gifts_selected][:count] += 1
        when 'gift_liked'
          @stats[:gifts_liked][:count] += 1
        when 'gift_disliked'
          @stats[:gifts_disliked][:count] += 1
        when 'recipient_invited'
          @stats[:recipients_invited][:count] += 1
        end
      end
      @stats
    end
    
    def preload_models
      preload_profiles
      preload_questions
      preload_gifts
    end
    
    protected
    
    def add_event(profile_id, type, ts, params = {})
      profile_events = (@events[profile_id] ||= [])
      profile_events << params.merge({type: type, ts: ts})
      params
    end
    
    def sort_events
      events.values.each do |profile_events|
        profile_events.sort! do |a, b|
          b[:ts] <=> a[:ts]
        end
      end
    end
    
    def sort_profile_ids
      @sorted_profile_ids = events.keys.sort do |a, b|
        events[b].first[:ts] <=> events[a].first[:ts]
      end
    end
    
    def preload_profiles
      @preloaded_profiles = {}
      ids = events.keys
      if ids.any?
        profiles = Profile.preload(:owner).where(id: ids)
        profiles.each do |profile|
          @preloaded_profiles[profile.id] = profile 
        end
      end
      @preloaded_profiles
    end

    def preload_questions
      @preloaded_questions = {}
      ids = events.values.flatten.map{|e| e[:question_id]}.compact.uniq
      if ids.any?
        questions = SurveyQuestion.preload(:survey).where(id: ids)
        questions.each do |question|
          @preloaded_questions[question.id] = question 
        end
      end
      @preloaded_questions
    end

    def preload_gifts
      @preloaded_gifts = {}
      ids = events.values.flatten.map{|e| e[:gift_id]}.compact.uniq
      if ids.any?
        gifts = Gift.where(id: ids)
        gifts.each do |gift|
          @preloaded_gifts[gift.id] = gift 
        end
      end
      @preloaded_gifts
    end

    def load_profile_created_events
      sql = %{select id, created_at from profiles where created_at #{date_range_sql}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'profile_created', row[1].to_time)
      end
    end

    def load_recipient_invited_events
      sql = %{select id, recipient_invited_at from profiles where recipient_invited_at #{date_range_sql}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'recipient_invited', row[1].to_time)
      end
    end

    def load_question_answered_events
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
        add_event(row[0].to_i, 'question_answered', row[2].to_time, question_id: row[1].to_i)
      end
    end

    def load_survey_completed_events
      sql = %{select profile_id, completed_at from survey_responses where completed_at #{date_range_sql}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'survey_completed', row[1].to_time)
      end
    end
    
    def load_gift_selected_events
      sql = %{select profile_id, created_at, gift_id from gift_selections where created_at #{date_range_sql}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'gift_selected', row[1].to_time, {gift_id: row[2].to_i})
      end
    end
    
    def load_gift_disliked_events
      sql = %{select profile_id, created_at, gift_id, reason from gift_dislikes where created_at #{date_range_sql}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'gift_disliked', row[1].to_time, {gift_id: row[2].to_i, reason: row[3].to_i})
      end
    end
    
    def load_gift_liked_events
      sql = %{select profile_id, created_at, gift_id, reason from gift_likes where created_at #{date_range_sql}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'gift_liked', row[1].to_time, {gift_id: row[2].to_i, reason: row[3].to_i})
      end
    end
    
    def date_range_sql
      "between '#{Profile.connection.quoted_date(begin_date)}' and '#{Profile.connection.quoted_date(end_date)}'"
    end
    
  end
end

