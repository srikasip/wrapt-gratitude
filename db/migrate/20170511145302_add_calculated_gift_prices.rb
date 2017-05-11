class AddCalculatedGiftPrices < ActiveRecord::Migration[5.0]
  def up
    execute(%{
      create view calculated_gift_fields as
        select g.id, g.id as gift_id,
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
          end as price
        from gifts as g
    })
    
    execute(%{
      create rule attempt_calculated_gift_fields_del as
        on delete to calculated_gift_fields do instead nothing
    })
    
    execute(%{
      create rule attempt_calculated_gift_fields_up as
        on update to calculated_gift_fields do instead nothing
    })
  end
  
  def down
    execute('drop view calculated_gift_fields')
  end
  
end
