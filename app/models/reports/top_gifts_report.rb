module Reports
  class TopGiftsReport
    attr_reader :begin_date, :end_date, :preloaded_gifts,
      :most_selected_gifts, :most_recommended_gifts
    
    def initialize(params)
      @begin_date = params[:begin_date]
      @end_date = params[:end_date]
      @most_recommended_gifts = []
      @most_selected_gifts = []
    end
    
    def load_most_recommended_gifts
      sql_selections = %{
        select count(gs.id)
        from gift_selections as gs
        where
          gs.gift_id = gr.gift_id and
          gs.profile_id in (#{profile_id_sql})
      }
      sql_likes = %{
        select count(gl.id)
        from gift_likes as gl
        where
          gl.gift_id = gr.gift_id and
          gl.profile_id in (#{profile_id_sql})
      }
      sql_dislikes = %{
        select count(gd.id)
        from gift_dislikes as gd
        where
          gd.gift_id = gr.gift_id and
          gd.profile_id in (#{profile_id_sql})
      }
      sql = %{
        select gr.gift_id, count(gr.id) as recommendation_count,
          avg(gr.position + 1) as avg_position, avg(gr.score) as avg_score,
          (#{sql_selections}) as selection_count,
          (#{sql_likes}) as liked_count,
          (#{sql_dislikes}) as disliked_count
        from gift_recommendations as gr
        join gift_recommendation_sets as grs on gr.recommendation_set_id = grs.id
        where grs.profile_id in (#{profile_id_sql})
        group by gr.gift_id
        order by recommendation_count desc, avg_position asc, avg_score desc
        limit 100
      }
      @most_recommended_gifts = GiftRecommendation.connection.select_all(sql)
    end
    
    def load_most_selected_gifts
      sql_recommended = %{
        select gift_id, count(gr.id) as recommendation_count,
          avg(position + 1) as avg_position, avg(score) as avg_score
        from gift_recommendations as gr
        join gift_recommendation_sets as grs on gr.recommendation_set_id = grs.id
        where grs.profile_id in (#{profile_id_sql})
        group by gift_id
      }
      sql_selection = %{
        select gift_id, count(id) as selection_count
        from gift_selections
        where profile_id in (#{profile_id_sql})
        group by gift_id
      }
      sql = %{
        select gs.gift_id, selection_count, recommendation_count, avg_position, avg_score
        from (#{sql_selection}) as gs
        join (#{sql_recommended}) as gr on gs.gift_id = gr.gift_id
        order by selection_count desc
        limit 100
      }
      @most_selected_gifts = GiftRecommendation.connection.select_all(sql)
    end
    
    def preload_gifts
      gift_ids = []
      [most_recommended_gifts, most_selected_gifts].each do |result_set|
        result_set.each do |result|
          gift_ids << result['gift_id']
        end
      end
      gift_ids = gift_ids.select(&:present?).uniq
      @preloaded_gifts = Gift.where(id: gift_ids).index_by(&:id)
    end
    
    def date_range_sql
      "between '#{Profile.connection.quoted_date(begin_date)}' and '#{Profile.connection.quoted_date(end_date)}'"
    end
    
    def profile_id_sql
      Profile.where(owner_id: User.external).where(created_at: [begin_date..end_date]).select(:id).to_sql
    end
    
  end
end

