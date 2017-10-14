class LineItem < ApplicationRecord
  belongs_to :order, polymorphic: true
  belongs_to :orderable, polymorphic: true
  belongs_to :vendor

  has_many :co_related_line_items, foreign_key: 'customer_order_line_items', class_name: 'RelatedLineItem', dependent: :destroy
  has_many :po_related_line_items, foreign_key: 'purchase_order_line_items', class_name: 'RelatedLineItem', dependent: :destroy

  delegate :name, to: :orderable
  delegate :name, to: :vendor, prefix: true
end
