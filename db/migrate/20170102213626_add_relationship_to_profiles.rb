class AddRelationshipToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :relationship, :string
  end
end
