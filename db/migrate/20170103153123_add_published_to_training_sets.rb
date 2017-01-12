class AddPublishedToTrainingSets < ActiveRecord::Migration[5.0]
  def change
    add_column :training_sets, :published, :boolean, index: true
  end
end
