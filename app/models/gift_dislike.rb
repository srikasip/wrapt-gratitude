class GiftDislike < ApplicationRecord

  belongs_to :gift
  belongs_to :profile

  enum reason: {giftee_similar_item: 0, giftee_dislike: 1, too_expensive: 2, owner_dislike: 3, no_reason: 4}
end