class GiftSelection < ApplicationRecord
  # Represents a gift that the gift giver has added to the basket

  belongs_to :profile
  belongs_to :gift

  validates :gift_id, uniqueness: {scope: :profile_id}
end
