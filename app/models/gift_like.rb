class GiftLike < ApplicationRecord
  belongs_to :gift
  belongs_to :profile

  enum reason: {
    a: 0,
    b: 1,
    c: 2,
    d: 3
  }
end
