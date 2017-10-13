class RelatedLineItem < ApplicationRecord
  belongs_to :purchase_order_line_item, class_name: 'LineItem', foreign_key: 'purchase_order_line_item_id'
  belongs_to :customer_order_line_item, class_name: 'LineItem', foreign_key: 'customer_order_line_item_id'
  belongs_to :purchase_order
  belongs_to :customer_order
end
