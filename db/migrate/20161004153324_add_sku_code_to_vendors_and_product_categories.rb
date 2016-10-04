class AddSkuCodeToVendorsAndProductCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :vendors, :wrapt_sku_code, :string
    add_column :product_categories, :wrapt_sku_code, :string

    Vendor.all.each do |vendor|
      vendor.update! wrapt_sku_code: vendor.name[0..1].upcase
    end

    ProductCategory.all.each do |vendor|
      vendor.update! wrapt_sku_code: vendor.name[0..1].upcase
    end


  end
end
