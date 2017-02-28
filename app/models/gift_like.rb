class GiftLike < ApplicationRecord
  belongs_to :gift
  belongs_to :profile

  enum reason: {
    maybe: 0,
    like: 1,
    really_like: 2,
    already_have_it: 3,
    would_like_more_options: 4
  }
end
