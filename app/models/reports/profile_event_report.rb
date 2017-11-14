module Reports
  class ProfileEventReport
    attr_reader :begin_date, :end_date,
      :preloaded_questions, :preloaded_profiles, :preloaded_gifts,
      :sorted_profile_ids, :events, :stats, :giftee_id

    def initialize(params)
      @begin_date = params[:begin_date]
      @end_date = params[:end_date]
      @giftee_id = params[:giftee_id]
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
      load_recommendations_generated_events
      load_recipient_gift_liked_events
      load_recipient_gift_disliked_events
      load_recipient_gift_selected_events

      sort_events
      sort_and_filter_profile_ids
    end

    def summary_report
      if @summary_report.blank?
        @summary_report = Reports::ProfileEventSummaryReport.new(self)
        @summary_report.load_stats
      end
      @summary_report
    end

    def generate_stats
      @stats = {
        profiles_created: 0,
        surveys_completed: 0,
        gifts_selected: 0,
        gifts_liked: 0,
        gifts_disliked: 0,
        recipients_invited: 0,
        recipient_gifts_selected: 0,
        recipient_gifts_liked: 0,
        recipient_gifts_disliked: 0,
        both_gifts_selected: 0,
        both_gifts_liked: 0,
        both_gifts_disliked: 0,
        recommended_gifts_selected: 0,
        recommended_gifts_liked: 0,
        recommended_gifts_disliked: 0,
        recipient_recommended_gifts_selected: 0,
        recipient_recommended_gifts_liked: 0,
        recipient_recommended_gifts_disliked: 0,
        both_recommended_gifts_selected: 0,
        both_recommended_gifts_liked: 0,
        both_recommended_gifts_disliked: 0,
      }

      profile_gifts = {liked: [], disliked: [], selected: []}
      recipient_profile_gifts = {liked: [], disliked: [], selected: []}
      profile_recommended_gifts = {liked: [], disliked: [], selected: []}
      recipient_profile_recommended_gifts = {liked: [], disliked: [], selected: []}

      events.values.flatten.each do |event|
        case event[:type]
        when 'profile_created'
          @stats[:profiles_created] += 1
        when 'survey_completed'
          @stats[:surveys_completed] += 1
        when 'gift_selected'
          @stats[:gifts_selected] += 1
          profile_gifts[:selected] << [event[:profile_id], event[:gift_id]]
        when 'gift_liked'
          @stats[:gifts_liked] += 1
          profile_gifts[:liked] << [event[:profile_id], event[:gift_id]]
        when 'gift_disliked'
          @stats[:gifts_disliked] += 1
          profile_gifts[:disliked] << [event[:profile_id], event[:gift_id]]
        when 'recipient_gift_selected'
          @stats[:recipient_gifts_selected] += 1
          recipient_profile_gifts[:selected] << [event[:profile_id], event[:gift_id]]
        when 'recipient_gift_liked'
          @stats[:recipient_gifts_liked] += 1
          recipient_profile_gifts[:liked] << [event[:profile_id], event[:gift_id]]
        when 'recipient_gift_disliked'
          @stats[:gifts_disliked] += 1
          recipient_profile_gifts[:disliked] << [event[:profile_id], event[:gift_id]]
        when 'recipient_invited'
          @stats[:recipients_invited] += 1
        end
      end

      @stats[:both_gifts_selected] = (profile_gifts[:selected] & recipient_profile_gifts[:selected]).size
      @stats[:both_gifts_liked] = (profile_gifts[:liked] & recipient_profile_gifts[:liked]).size
      @stats[:both_gifts_disliked] = (profile_gifts[:disliked] & recipient_profile_gifts[:disliked]).size

      @stats
    end

    def preload_models
      preload_profiles
      preload_questions
      preload_gifts
    end

    protected

    def profile_clause
      @profile_clause ||= self.giftee_id.present? ? "profiles.id = #{self.giftee_id.to_i}" : 'true'
    end

    def parse_time(ts)
      tz = ActiveSupport::TimeZone["UTC"]
      tz.parse(ts).localtime
    end

    def add_event(profile_id, type, ts, params = {})
      profile_events = (@events[profile_id] ||= [])
      profile_events << params.merge({profile_id: profile_id, type: type, ts: ts})
      params
    end

    def sort_events
      events.values.each do |profile_events|
        profile_events.sort! do |a, b|
          b[:ts] <=> a[:ts]
        end
      end
    end

    def sort_and_filter_profile_ids
      filtered_profile_ids = \
        if self.giftee_id.present?
          events.keys.select do |event|
            event == self.giftee_id.to_i
          end
      else
        events.keys
      end

      @sorted_profile_ids = filtered_profile_ids.sort do |a, b|
        events[b].first[:ts] <=> events[a].first[:ts]
      end
    end

    def preload_profiles
      @preloaded_profiles = {}
      ids = events.keys
      if ids.any?
        profiles = Profile.preload(:owner, {gift_recommendations: [:gift]}).where(id: ids)
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
      sql = %{select id, created_at from profiles where created_at #{date_range_sql} and #{profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'profile_created', parse_time(row[1]))
      end
    end

    def load_recipient_invited_events
      sql = %{select id, recipient_invited_at from profiles where recipient_invited_at #{date_range_sql} and #{profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'recipient_invited', parse_time(row[1]))
      end
    end

    def load_question_answered_events
      another_profile_clause = self.giftee_id.present? ? "sr.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{
        select profile_id, survey_question_id, ts
        from (
          select sr.profile_id, sqr.survey_question_id, sqr.answered_at as ts,
          row_number() over (partition by sr.profile_id order by sqr.answered_at desc) as rn
          from survey_question_responses as sqr
          join survey_responses as sr on sqr.survey_response_id = sr.id
          where sqr.answered_at #{date_range_sql}
          and #{another_profile_clause}
        ) as t
        where rn = 1
      }
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'question_answered', parse_time(row[2]), question_id: row[1].to_i)
      end
    end

    def load_recommendations_generated_events
      another_profile_clause = self.giftee_id.present? ? "gift_recommendations.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{
        select profile_id, max(created_at) from gift_recommendations
        where created_at #{date_range_sql} and #{another_profile_clause} group by profile_id
      }
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'recommendations_generated', parse_time(row[1]))
      end
    end

    def load_survey_completed_events
      another_profile_clause = self.giftee_id.present? ? "survey_responses.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{select profile_id, completed_at, id from survey_responses where completed_at #{date_range_sql} and #{another_profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'survey_completed', parse_time(row[1]), {survey_id: row[2].to_i})
      end
    end

    def load_gift_selected_events
      another_profile_clause = self.giftee_id.present? ? "gift_selections.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{select profile_id, created_at, gift_id from gift_selections where created_at #{date_range_sql} and #{another_profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'gift_selected', parse_time(row[1]), {gift_id: row[2].to_i})
      end
    end

    def load_gift_disliked_events
      reason_lookup = GiftDislike.reasons.invert
      another_profile_clause = self.giftee_id.present? ? "gift_dislikes.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{select profile_id, created_at, gift_id, reason from gift_dislikes where created_at #{date_range_sql} and #{another_profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        reason = reason_lookup[row[3].to_i] || ''
        add_event(row[0].to_i, 'gift_disliked', parse_time(row[1]), {gift_id: row[2].to_i, reason: reason})
      end
    end

    def load_gift_liked_events
      reason_lookup = GiftLike.reasons.invert
      another_profile_clause = self.giftee_id.present? ? "gift_likes.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{select profile_id, created_at, gift_id, reason from gift_likes where created_at #{date_range_sql} and #{another_profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        reason = reason_lookup[row[3].to_i] || ''
        add_event(row[0].to_i, 'gift_liked', parse_time(row[1]), {gift_id: row[2].to_i, reason: reason})
      end
    end

    def load_recipient_gift_selected_events
      another_profile_clause = self.giftee_id.present? ? "recipient_gift_selections.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{select profile_id, created_at, gift_id from recipient_gift_selections where created_at #{date_range_sql} and #{another_profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        add_event(row[0].to_i, 'recipient_gift_selected', parse_time(row[1]), {gift_id: row[2].to_i})
      end
    end

    def load_recipient_gift_disliked_events
      reason_lookup = RecipientGiftDislike.reasons.invert
      another_profile_clause = self.giftee_id.present? ? "recipient_gift_dislikes.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{select profile_id, created_at, gift_id, reason from recipient_gift_dislikes where created_at #{date_range_sql} and #{another_profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        reason = reason_lookup[row[3].to_i] || ''
        add_event(row[0].to_i, 'recipient_gift_disliked', parse_time(row[1]), {gift_id: row[2].to_i, reason: reason})
      end
    end

    def load_recipient_gift_liked_events
      reason_lookup = RecipientGiftLike.reasons.invert
      another_profile_clause = self.giftee_id.present? ? "recipient_gift_likes.profile_id = #{self.giftee_id.to_i}" : "true"
      sql = %{select profile_id, created_at, gift_id, reason from recipient_gift_likes where created_at #{date_range_sql} and #{another_profile_clause}}
      Profile.connection.select_rows(sql).each do |row|
        reason = reason_lookup[row[3].to_i] || ''
        add_event(row[0].to_i, 'recipient_gift_liked', parse_time(row[1]), {gift_id: row[2].to_i, reason: reason})
      end
    end

    def date_range_sql
      "between '#{Profile.connection.quoted_date(begin_date)}' and '#{Profile.connection.quoted_date(end_date)}'"
    end
  end
end

