class GiftRecommendation < ApplicationRecord
  
  belongs_to :survey_response
  belongs_to :profile
  belongs_to :gift
  
  MAX_SHOWN_TO_USER = 6
  MAX_SHOWN_TO_USER_MOBILE = 4
  
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
  
  def self.select_for_display(gift_recommendations, page=1, mobile: false)
    expert_picks = gift_recommendations.select(&:added_by_expert)
    auto_picks = gift_recommendations - expert_picks
    max = mobile ? MAX_SHOWN_TO_USER_MOBILE : MAX_SHOWN_TO_USER
    if page == 'all'
      expert_picks + auto_picks
    else
      if mobile
        start_picks = page == 1 ? 0 : (page-1)*max
        end_picks = (max*page) - 1
        (expert_picks + auto_picks)[start_picks..end_picks] || []
      else
        end_picks = (max*page) - 1
        (expert_picks + auto_picks)[0..end_picks] || []
      end
    end
  end

  def self.pages(gift_recommendations, mobile: false)
    max = mobile ? MAX_SHOWN_TO_USER_MOBILE : MAX_SHOWN_TO_USER
    gift_recommendations.in_groups_of(max, false).size
  end

  def self.max(mobile: false)
    mobile ? MAX_SHOWN_TO_USER_MOBILE : MAX_SHOWN_TO_USER
  end

end
