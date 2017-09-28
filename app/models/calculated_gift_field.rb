class CalculatedGiftField < ApplicationRecord
  include IsADatabaseView

  belongs_to :gift

  def readonly?
    true
  end

  def self.view_definition
    _ = <<~SQL
      select
        g.id,
        g.id as gift_id,

        case
        when g.calculate_cost_from_products then
          (
            select sum(p.wrapt_cost)
            from products as p
            join gift_products as gp on gp.gift_id = g.id and gp.product_id = p.id
          )
        else
          g.cost
        end as cost,

        case
        when g.calculate_price_from_products then
          (
            select sum(p.price)
            from products as p
            join gift_products as gp on gp.gift_id = g.id and gp.product_id = p.id
          )
        else
          g.selling_price
        end as price,

        case
        when g.calculate_weight_from_products then
          (
            select sum(p.weight_in_pounds)
            from products as p
            join gift_products as gp on gp.gift_id = g.id and gp.product_id = p.id
          )
        else
          g.weight_in_pounds
        end as weight_in_pounds,

        (
          select COALESCE(min(p.units_available), 0)
          from products as p
          join gift_products as gp on gp.gift_id = g.id and gp.product_id = p.id
        ) as units_available

      from gifts as g
    SQL
  end
end
