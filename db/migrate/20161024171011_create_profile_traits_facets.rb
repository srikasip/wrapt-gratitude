class CreateProfileTraitsFacets < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_traits_facets do |t|
      t.references :topic
      t.string :name

      t.timestamps
    end
    add_foreign_key :profile_traits_facets, :profile_traits_topics, column: :topic_id
  end
end
