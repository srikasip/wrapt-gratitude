class RecipientGiftDislike < ApplicationRecord
  belongs_to :gift
  belongs_to :profile

  validates :gift, uniqueness: {scope: :profile}

  enum reason: {giftee_similar_item: 0, giftee_dislike: 1, too_expensive: 2, no_reason: 4}

end
