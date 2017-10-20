# We have line items in customer and purchase orders. Each one matches up with
# one or more line items from the other type of order. One gift in a customer
# order can match up with one or more products in a purchase order. Though, a
# product in a purchase order can only match up with one gift in customer order.
class RelatedLineItem < ApplicationRecord
  belongs_to :purchase_order_line_item, class_name: 'LineItem', foreign_key: 'purchase_order_line_item_id'
  belongs_to :customer_order_line_item, class_name: 'LineItem', foreign_key: 'customer_order_line_item_id'
  belongs_to :purchase_order
  belongs_to :customer_order
end
