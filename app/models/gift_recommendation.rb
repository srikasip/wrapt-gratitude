class GiftRecommendation < ApplicationRecord
  belongs_to :survey_response
  belongs_to :gift
  belongs_to :profile

  def gift_dislike
    GiftDislike.where(profile: profile, gift: gift).first
  end

  def disliked?
    gift_dislike.present?
  end

  def dislike_options
    [
      {text: "#{profile.name} already has something like this", href: '#', data: {value: 'giftee_similar_item'}},
      {text: "#{profile.name} doesn't like gifts like this", href: '#', data: {value: 'giftee_dislike'}},
      {text: "It's too expensive", href: '#', data: {value: 'too_expensive'}},
      {text: "I don't like it", href: '#', data: {value: 'owner_dislike'}},
      {text: 'None of these', href: '#', data: {value: 'no_reason'}}
    ]
  end
end
