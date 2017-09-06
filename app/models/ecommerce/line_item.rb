class LineItem < ApplicationRecord
  belongs_to :order, polymorphic: true
  belongs_to :orderable, polymorphic: true
  belongs_to :vendor

  delegate :name, to: :orderable
  delegate :name, to: :vendor, prefix: true
end
