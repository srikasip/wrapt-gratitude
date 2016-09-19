class GiftQuestionImpactsReferenceGiftsNotProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :gift_question_impacts, :product_id
    change_table :gift_question_impacts do |t|
      t.references :gift, foreign_key: true, null: false
    end
  end
end
