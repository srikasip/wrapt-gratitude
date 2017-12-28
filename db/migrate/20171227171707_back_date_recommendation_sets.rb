class BackDateRecommendationSets < ActiveRecord::Migration[5.0]
  def up
    sql = %{
      update gift_recommendation_sets as grs
      set updated_at = max_updated_at, created_at = min_created_at
      from (
        select
        recommendation_set_id as id,
        max(updated_at) as max_updated_at,
        min(created_at) as min_created_at
        from gift_recommendations
        group by recommendation_set_id
      ) as t
      where t.id = grs.id
    }
    GiftRecommendationSet.connection.execute(sql)
  end
end
