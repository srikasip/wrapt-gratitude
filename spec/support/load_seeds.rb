RSpec.configure do |c|
  c.before(:suite) do
    category = ProductCategory.where(name: 'Test Gift', wrapt_sku_code: 'TST').first_or_initialize
    category.save!

    sub_category = ProductCategory.where(name: 'Test Gift Subcategory', wrapt_sku_code: 'TSS').first_or_initialize
    sub_category.save!

    category.children << sub_category

    load 'db/seeds.rb'
  end
end
