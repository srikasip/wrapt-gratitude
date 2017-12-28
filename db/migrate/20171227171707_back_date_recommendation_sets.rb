class BackDateRecommendationSets < ActiveRecord::Migration[5.0]
  def up
    sql = %{
      update gift_recommendation_sets set
      updated_at = (select max(gr.updated_at) from gift_recommendations as gr where gr.recommendation_set_id = grs.id),
      created_at = (select min(gr.created_at) from gift_recommendations as gr where gr.recommendation_set_id = grs.id)
      from gift_recommendation_sets as grs
    }
    GiftRecommendationSet.connection.execute(sql)
  end
end
