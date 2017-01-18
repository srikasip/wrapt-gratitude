class GiftDislike < ApplicationRecord

  belongs_to :gift
  belongs_to :profile

  enum reason: [:giftee_similar_item, :giftee_dislike, :too_expensive, :owner_dislike, :no_reason]

  def display_reason(key)
    {
      giftee_similar_item: "#{profile.name} already has something like this",
      giftee_dislike: "#{profile.name} doesn't like gifts like this",
      too_expensive: "It's too expensive",
      owner_dislike: "I don't like it",
      no_reason: 'None of these'
    }
  end
end