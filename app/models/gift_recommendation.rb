class GiftRecommendation < ApplicationRecord
  belongs_to :survey_response
  belongs_to :gift
  belongs_to :profile
  
  delegate :featured?, :experience?, to: :gift

  def gift_dislike
    GiftDislike.where(profile: profile, gift: gift).first || GiftDislike.new(profile: profile, gift: gift)
  end

  def disliked?
    !gift_dislike.new_record?
  end
  
  def random?
    score < Recommendations::Engine::RECOMMENDATION_SCORE_THRESHOLD
  end

end
