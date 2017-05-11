module Recommender
  class Engine
    
    attr_reader :survey_response, :recommendations, :filters, :scorers,
      :max_total, :gift_scope
    
    delegate :profile, :survey, :question_responses, to: :survey_response
    
    def initialize(survey_response)
      @survey_response = survey_response
      
      @max_total = 12
      
      reset
    end
    
    def run
      reset
      
      preload_models
      load_filters
      build_gift_scope
      load_scorers
      generate_gift_scores
      generate_recommendations
      
      @recommendations
    end
    
    def reset
      @recommendations = []
      @filters = []
      @scorers = []
      @gift_scope = nil
      @gift_scores = []
    end
    
    def create_recommendations!
      @gift_recommendations.map(&:save)
    end
    
    def destroy_recommendations!
      GiftRecommendation.where(profile: profile).destroy_all
    end
    
    def load_filters
      @filters = Recommender::Filtering::Base.create_filters(self)
    end
    
    def load_scorers
      @scorers = Recommender::Scoring::Base.create_scorers(self)
    end
    
    def preload_models
      preloader = ActiveRecord::Associations::Preloader.new
      preloader.preload([@survey_response],
        [
          :profile,
          :survey,
          question_responses: [:survey_question_options]
        ]
      )
    end
    
    def build_gift_scope
      @gift_scope = Gift.all
      filters.each do |filter|
        @gift_scope = @gift_scope.where(id: filter.gift_scope)
      end
      @gift_scope
    end
        
    def generate_gift_scores
      sql_union_scorers = scorers.map(&:scoring_sql).join(' UNION ')
      sql_scores = %{
        select id, sum(score) as score
        from (#{sql_union_scorers}) as raw
        group by id
        order by score desc, random()
        limit #{max_total}
      }
      rows = Gift.connection.select_rows(sql_scores)
      
      @gift_scores = rows.map do |row|
        {id: row[0].to_i, score: row[1].to_f}
      end
    end
    
    def generate_recommendations
      @gift_scores.each_with_index do |gift_score, position|
        recommendation = GiftRecommendation.new(
          gift_id: gift_score[:id],
          score: gift_score[:score],
          position: position,
          profile: profile
        )
        recommendations << recommendation
      end
    end
    
  end
end