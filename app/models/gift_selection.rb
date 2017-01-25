class GiftSelection < ApplicationRecord
  # Represents a gift that has been added to the basket

  belongs_to :profile
  belongs_to :gift

  validates :gift_id, uniqueness: {scope: :profile_id}
end
