class NormalizeRecommendationPositions < ActiveRecord::Migration[5.0]
  def up
    GiftRecommendationSet.all.each do |rec_set|
      rec_set.recommendations.reorder(expert_score: :desc, position: :asc, score: :desc, id: :asc).each_with_index do |rec, position|
        rec.update_attribute(:position, position)
      end
    end
  end
end
