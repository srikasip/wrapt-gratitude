class CreateProfileTraitsTags < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_traits_tags do |t|
      t.references :facet
      t.string :name
      t.integer :position
      t.timestamps
    end
    add_foreign_key :profile_traits_tags, :profile_traits_facets, column: :facet_id
  end
end
