class WeightCalculationInView < ActiveRecord::Migration[5.0]
  def up
    add_column :gifts, :calculate_weight_from_products, :boolean, null: false, default: true
    add_column :gifts, :weight_in_pounds, :numeric
    add_column :products, :weight_in_pounds, :numeric

    begin
      say_with_time "Rebuilding gift field view if possible" do
        CalculatedGiftField.rebuild_view!
      end
    rescue StandardError => e
      puts "DATA MIGRATION FAILED in #{__FILE__}: #{e.message}"
    end
  end

  def down
    execute("drop view calculated_gift_fields")

    remove_column :gifts, :calculate_weight_from_products
    remove_column :gifts, :weight_in_pounds
    remove_column :products, :weight_in_pounds

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
  end
end
