class AddReasonToGiftLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_likes, :reason, :integer
  end
end
