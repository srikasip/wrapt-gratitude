class GiftRecommendation < ApplicationRecord
  
  belongs_to :survey_response
  belongs_to :profile
  belongs_to :gift
  
  delegate :featured?, :experience?, to: :gift

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

end
