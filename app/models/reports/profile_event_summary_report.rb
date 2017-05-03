module Reports
  class ProfileEventSummaryReport
    attr_reader :event_report, :profile_stats, :aggregate_stats
    delegate :events, :preloaded_profiles, :preloaded_gifts, to: :event_report
    
    def initialize(event_report)
      @event_report = event_report
      @aggregate_stats = {}
      @profile_stats = {}
    end
       
    def load_stats
      load_profile_stats
      load_aggregate_stats
    end
    
    protected
    
    def load_aggregate_stats
      @aggregate_stats = build_aggregate_stats_record

      count_keys = @aggregate_stats.keys.select do |key|
        key.to_s.ends_with?('_count')
      end
      
      @profile_stats.each do |profile_id, profile_record|
        # sum up the count fields
        count_keys.each do |key|
          @aggregate_stats[key] += profile_record[key] if profile_record.has_key?(key)
        end
      end
    end
    
    def load_profile_stats
      @profile_stats = {}
      
      events.each do |profile_id, profile_events|
        profile = preloaded_profiles[profile_id]
        next if profile.blank?

        record = build_profile_stats_record
        generate_profile_stats(record, profile, profile_events)
        
        @profile_stats[profile_id] = record
      end
    end
    
    def generate_profile_stats(record, profile, profile_events)
      # get the recommended gifts that were generated via the algorithm (non-random)
      non_random_gifts = profile.gift_recommendations.reject(&:random?).map(&:gift)
      
      # gather up the gift models for calculating some more interesting stats
      event_gifts = {
        gift_liked: [],
        gift_disliked: [],
        gift_selected: [],
        recipient_gift_liked: [],
        recipient_gift_disliked: [],
        recipient_gift_selected: []
      }
      
      profile_events.each do |event|
        # sum up the count fields
        count_key = "#{event[:type]}_count".to_sym 
        record[count_key] += 1 if record.has_key?(count_key)
        
        # gather up the gifts in the events
        if event.has_key?(:gift_id)
          gift = preloaded_gifts[event[:gift_id]]
          event_gift_key = event[:type].to_sym 
          if gift && event_gifts.has_key?(event_gift_key)
            event_gifts[event_gift_key] << gift
          end
        end
      end
      
      both_selected_gifts = event_gifts[:gift_selected] & event_gifts[:recipient_gift_selected]
      record[:both_gift_selected_count] = both_selected_gifts.size
      record[:both_recommended_gift_selected_count] = (both_selected_gifts & non_random_gifts).size
      record[:recommended_gift_selected_count] = (event_gifts[:gift_selected] & non_random_gifts).size
      record[:recipient_recommended_gift_selected_count] = (event_gifts[:recipient_gift_selected] & non_random_gifts).size

      both_liked_gifts = event_gifts[:gift_liked] & event_gifts[:recipient_gift_liked]
      record[:both_gift_liked_count] = both_liked_gifts.size
      record[:both_recommended_gift_liked_count] = (both_liked_gifts & non_random_gifts).size
      record[:recommended_gift_liked_count] = (event_gifts[:gift_liked] & non_random_gifts).size
      record[:recipient_recommended_gift_liked_count] = (event_gifts[:recipient_gift_liked] & non_random_gifts).size

      both_disliked_gifts = event_gifts[:gift_disliked] & event_gifts[:recipient_gift_disliked]
      record[:both_gift_disliked_count] = both_disliked_gifts.size
      record[:both_recommended_gift_disliked_count] = (both_disliked_gifts & non_random_gifts).size
      record[:recommended_gift_disliked_count] = (event_gifts[:gift_disliked] & non_random_gifts).size
      record[:recipient_recommended_gift_disliked_count] = (event_gifts[:recipient_gift_disliked] & non_random_gifts).size
      
      record
    end
    
    def build_profile_stats_record
      {
        profile_created_count: 0,
        survey_completed_count: 0,
        recipient_invited_count: 0,
        
        gift_selected_count: 0,
        gift_liked_count: 0,
        gift_disliked_count: 0,

        recipient_gift_selected_count: 0,
        recipient_gift_liked_count: 0,
        recipient_gift_disliked_count: 0,
        
        both_gift_selected_count: 0,
        both_gift_liked_count: 0,
        both_gift_disliked_count: 0,
        
        recommended_gift_selected_count: 0,
        recommended_gift_liked_count: 0,
        recommended_gift_disliked_count: 0,
        
        recipient_recommended_gift_selected_count: 0,
        recipient_recommended_gift_liked_count: 0,
        recipient_recommended_gift_disliked_count: 0,
        
        both_recommended_gift_selected_count: 0,
        both_recommended_gift_liked_count: 0,
        both_recommended_gift_disliked_count: 0,
      }
    end

    def build_aggregate_stats_record
      build_profile_stats_record
    end
  end
end

