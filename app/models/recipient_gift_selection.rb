class RecipientGiftSelection < ApplicationRecord
  # represents a gift that the recipient has added to the basket

  belongs_to :profile
  belongs_to :gift

  validates :gift_id, uniqueness: {scope: :profile_id}
end
