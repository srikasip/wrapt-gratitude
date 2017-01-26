class GiftRecommendation < ApplicationRecord
  belongs_to :survey_response
  belongs_to :gift
  belongs_to :profile

  def gift_dislike
    GiftDislike.where(profile: profile, gift: gift).first || GiftDislike.new(profile: profile, gift: gift)
  end

  def disliked?
    !gift_dislike.new_record?
  end

end