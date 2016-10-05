class GenerateSkuCodes < ActiveRecord::Migration[5.0]
  def change
    Vendor.all.each do |vendor|
      vendor.update! wrapt_sku_code: vendor.name[0..1].upcase
    end

    ProductCategory.all.each do |product_category|
      product_category.update! wrapt_sku_code: product_category.name[0..2].upcase
    end

    Product.all.each do |product|
      product.generate_wrapt_sku
      product.save validate: false
    end

    Gift.all.each do |gift|
      gift.generate_wrapt_sku
      gift.save validate: false
    end

  end
end
