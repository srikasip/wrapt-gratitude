class GiftSelection < ApplicationRecord
  # Represents a gift that has been added to the basket

  belongs_to :profile
  belongs_to :gift
end
