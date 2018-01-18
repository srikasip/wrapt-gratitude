module Recommender
  class SurveyResponseEngine < EngineBase

    attr_reader :survey_response, :filters, :scorers, :gift_scope, :max_total_new

    delegate :survey, :question_responses, to: :survey_response

    def initialize(recommendation_set)
      super(recommendation_set)
      
      @max_total_new = recommendation_set.engine_params[:max_total_new] ||= 12
      
      load_survey_response
    end

    def run
      super

      load_filters
      build_gift_scope
      load_scorers
      generate_gift_scores
      sort_gift_scores
      filter_gift_scores
      generate_recommendations

      @recommendations
    end

    def reset
      super
      @filters = []
      @scorers = []
      @gift_scope = nil
      @gift_scores = []
    end

    def load_filters
      @filters = Recommender::Filtering::Base.create_filters(self)
      @stats[:filters] = @filters.map do |filter|
        {name: filter.name, description: filter.description}
      end
      @filters
    end

    def load_scorers
      @scorers = Recommender::Scoring::Base.create_scorers(self)
      @stats[:scorers] = @scorers.map do |scorer|
        {name: scorer.name, description: scorer.description}
      end
      @scorers
    end

    def build_gift_scope
      @gift_scope = Gift.can_be_sold
      filters.each do |filter|
        @gift_scope = if filter.exclusive_scope?
          @gift_scope.where("gifts.id not in (#{filter.gift_scope.to_sql})")
        else
          @gift_scope.where("gifts.id in (#{filter.gift_scope.to_sql})")
        end
      end
      if recommendation_set.recommendations.any?
        #excluded any gift currently in the set
        t = Gift.arel_table
        @gift_scope.where(t[:id].not_in(recommendation_set.recommendations.map(&:gift_id)))
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
        limit #{20 * max_total_new}
      }
      rows = Gift.connection.select_rows(sql_scores)

      @gift_scores = rows.map do |row|
        {id: row[0].to_i, score: row[1].to_f}
      end
    end

    def sort_gift_scores
      sorter = Recommender::PostProcessing::DistributedSort.new(@gift_scores)
      @gift_scores = sorter.sort
    end

    def filter_gift_scores
      filter = Recommender::PostProcessing::UniqueProductFilter.new(@gift_scores, max_total_new)
      @gift_scores = filter.filter
    end

    def generate_recommendations
      @gift_scores.take(max_total_new).each_with_index do |gift_score, position|
        recommendation = GiftRecommendation.new(
          gift_id: gift_score[:id],
          score: gift_score[:score],
          position: position
        )
        recommendations << recommendation
      end
    end
    
    def load_survey_response
      scope = SurveyResponse.preload([
          :profile,
          :survey,
          question_responses: [:survey_question_options]
        ])
      
      if engine_params[:survey_response_id].present?
        scope = scope.where(id: engine_params[:survey_response_id])
      else
        scope = scope.where(profile_id: profile.id).order(created_at: :desc)
      end
      
      @survey_response = scope.first!
      
      engine_params[:survey_response_id] = @survey_response.id
      
      return @survey_response
    end

  end
end
