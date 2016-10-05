class GenerateWraptSkusForProductsAndGifts < ActiveRecord::Migration[5.0]
  def change
    Product.all.each do |product|
      product.generate_wrapt_sku
      product.save! validate: false
    end

    Gift.all.each do |gift|
      gift.generate_wrapt_sku
      gift.save! validate: false
    end
  end
end
