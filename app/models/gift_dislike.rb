class GiftDislike < ApplicationRecord

  belongs_to :gift
  belongs_to :profile

  enum reason: {giftee_similar_item: 0, giftee_dislike: 1, too_expensive: 2, owner_dislike: 3, no_reason: 4}

  def display_reason(key)
    labels = {
      giftee_similar_item: "Already has this",
      giftee_dislike: "Wouldn't like it",
      too_expensive: "Too expensive",
      owner_dislike: "Just don't like it",
      no_reason: 'None of these'
    }
    labels[key.to_sym]
  end
end