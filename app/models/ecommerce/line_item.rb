class LineItem < ApplicationRecord
  belongs_to :order, polymorphic: true
  belongs_to :orderable, polymorphic: true
end
