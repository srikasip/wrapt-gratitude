class RecipientGiftLike < ApplicationRecord
  belongs_to :profile
  belongs_to :gift

  validates :gift, uniqueness: {scope: :profile}

  enum reason: {
    a: 0,
    b: 1,
    c: 2,
    d: 3
  }
end
