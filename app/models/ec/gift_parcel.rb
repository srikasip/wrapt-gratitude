module Ec
  class GiftParcel < ApplicationRecord
    belongs_to :gift
    belongs_to :parcel
  end
end
