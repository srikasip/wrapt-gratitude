class GiftLike < ApplicationRecord
  belongs_to :gift
  belongs_to :profile
end
