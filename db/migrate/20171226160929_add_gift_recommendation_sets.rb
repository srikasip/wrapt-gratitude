class AddGiftRecommendationSets < ActiveRecord::Migration[5.0]
  def up
    create_table :gift_recommendation_sets do |t|
      t.integer :profile_id, null: false, index: true
      t.string :engine_type
      t.text :engine_params
      t.text :engine_stats
      t.timestamps
    end
    
    add_column :gift_recommendations, :recommendation_set_id, :integer, index: true
    
    #move all of the recommendations into a recommendation set on the profile
    Profile.each do |profile|
      rec_set = profile.gift_recommendation_sets.build(
        engine_type: 'survey_response_engine',
        engine_stats: profile.recommendation_stats
      )
      rec_set.engine_params['survey_response_id'] = profile.survey_responses.first&.id
      rec_set.save!
      GiftRecommendation.where(profile_id: profile.id).update_all(recommendation_set_id: rec_set.id)
    end
    
    rename_column :gift_recommendations, :profile_id, :deprecated_profile_id
    remove_column :profiles, recommendation_stats
    
    change_column_null :gift_recommendations, :recommendation_set_id, false
    change_column_null :gift_recommendations, :deprecated_profile_id, true
  end
end
