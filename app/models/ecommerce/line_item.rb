class LineItem < ApplicationRecord
  belongs_to :order, polymorphic: true
  belongs_to :orderable, polymorphic: true
  belongs_to :vendor

  has_many :co_related_line_items_nexus, foreign_key: 'customer_order_line_item_id', class_name: 'RelatedLineItem', dependent: :destroy
  has_one :po_related_line_item_nexus, foreign_key: 'purchase_order_line_item_id', class_name: 'RelatedLineItem', dependent: :destroy


  has_many :co_related_line_items, through: :co_related_line_items_nexus, source: :purchase_order_line_item
  has_one :po_related_line_item, through: :po_related_line_item_nexus, source: :customer_order_line_item

  delegate :name, to: :orderable
  delegate :name, to: :vendor, prefix: true

  def related_line_items
    if order.is_a? CustomerOrder
      co_related_line_items
    elsif order.is_a? PurchaseOrder
      [po_related_line_item]
    else
      raise "related line items requested for an unknown order type"
    end
  end
end
