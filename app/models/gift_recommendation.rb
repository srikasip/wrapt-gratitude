class GiftRecommendation < ApplicationRecord
  
  belongs_to :gift
  belongs_to :recommendation_set, class_name: 'GiftRecommendationSet'
  
  delegate :profile, to: :recommendation_set
  
  MAX_SHOWN_TO_USER = 6
  
  delegate :featured?, :experience?, to: :gift
  
  def self.available
    where(gift_id: Gift.select(:id).can_be_sold, removed_by_expert: false)
  end

  def gift_dislike
    GiftDislike.where(profile: profile, gift: gift).first || GiftDislike.new(profile: profile, gift: gift)
  end

  def disliked?
    !gift_dislike.new_record?
  end

  def random?
    score == 0
  end
  
  def normalize_expert_score
    if added_by_expert?
      self.expert_score = [[expert_score, 1.0].max, 10.0].min
    else
      self.expert_score = 0.0
    end
    true
  end
  before_save :normalize_expert_score

  def self.load_recommendations_for_display(gift_recommendations)
    expert_picks = gift_recommendations.reject(&:removed_by_expert).select(&:added_by_expert)
    auto_picks = (gift_recommendations - expert_picks || []).take(12)
    all_picks = expert_picks + auto_picks || []
  end
  
  def self.select_for_display(gift_recommendations, page=1, mobile: false)
    all_picks = load_recommendations_for_display(gift_recommendations)
    if page == 'all'
      picks_to_show = all_picks
    else
      all_picks_by_page = all_picks.in_groups_of(max, false)
      page_index = page - 1
      last_page_index = all_picks_by_page.size - 1
      if page_index < 0
        page_index = 0
      elsif page_index > last_page_index
        page_index = last_page_index
      end
      picks_to_show = all_picks_by_page[page_index]
    end
    picks_to_show
  end

  def self.pages(gift_recommendations, mobile: false)
    max = MAX_SHOWN_TO_USER
    all_picks = load_recommendations_for_display(gift_recommendations)
    all_picks.in_groups_of(max, false).size
  end

  def self.max(mobile: false)
    MAX_SHOWN_TO_USER
  end

end
