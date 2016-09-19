class RenameGiftNameToTitle < ActiveRecord::Migration[5.0]
  def change
    rename_column :gifts, :name, :title
  end
end
