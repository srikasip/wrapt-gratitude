class RegenerateGiftSkus < ActiveRecord::Migration[5.0]
  def change
    Gift.all do |gift|
      gift.generate_wrapt_sku!
    end
  end
end
