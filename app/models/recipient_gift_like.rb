class RecipientGiftLike < ApplicationRecord
  belongs_to :profile
  belongs_to :gift

  validates :gift, uniqueness: {scope: :profile}
end
