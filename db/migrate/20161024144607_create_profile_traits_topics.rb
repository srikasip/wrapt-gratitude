class CreateProfileTraitsTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_traits_topics do |t|
      t.string :name

      t.timestamps
    end
  end
end
