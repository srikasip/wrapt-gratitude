class AddGiftRecommendationSets < ActiveRecord::Migration[5.0]
  def up
    create_table :gift_recommendation_sets do |t|
      t.integer :profile_id, null: false, index: true
      t.string :engine_type
      t.text :engine_params
      t.text :engine_stats
      t.text :expert_note
      t.integer :expert_id
      t.timestamps
    end
    
    add_column :gift_recommendations, :recommendation_set_id, :integer, index: true
    
    Profile.reset_column_information
    GiftRecommendation.reset_column_information
    GiftRecommendationSet.reset_column_information
      
    #move all of the recommendations into a recommendation set on the profile
    Profile.each do |profile|
      rec_set = profile.gift_recommendation_sets.build(engine_type: 'survey_response_engine')
      rec_set.engine_params['survey_response_id'] = profile.survey_responses.first&.id
      rec_set.engine_stats = profile.recommendation_stats
      rec_set.expert_note = profile.expert_note
      rec_set.expert_id = profile.expert_id
      rec_set.save!
      GiftRecommendation.where(profile_id: profile.id).update_all(recommendation_set_id: rec_set.id)
    end
    
    #keep the profile_id column for a bit just in case something goes wrong it will make it easier to recover
    rename_column :gift_recommendations, :profile_id, :deprecated_profile_id
    change_column_null :gift_recommendations, :deprecated_profile_id, true
    
    remove_column :profiles, :recommendation_stats
    remove_column :profiles, :expert_note
    remove_column :profiles, :expert_id
    
    change_column_null :gift_recommendations, :recommendation_set_id, false
  end
end
