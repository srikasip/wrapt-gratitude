class AddProfileTraitsTagToTraitResponseImpacts < ActiveRecord::Migration[5.0]
  def change
    add_reference :trait_response_impacts, :profile_traits_tag, foreign_key: true
  end
end
