module Recommender
  class Engine

    attr_reader :survey_response, :recommendations, :filters, :scorers,
      :max_total, :gift_scope, :stats

    delegate :profile, :survey, :question_responses, to: :survey_response

    def initialize(survey_response)
      @survey_response = survey_response

      @max_total = 18

      reset
    end

    def run
      reset

      preload_models
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
      @recommendations = []
      @filters = []
      @scorers = []
      @gift_scope = nil
      @gift_scores = []
      @stats = {}
    end

    def create_recommendations!
      @recommendations.map(&:save)
    end

    def destroy_recommendations!
      GiftRecommendation.where(profile: profile).destroy_all
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
      @gift_scope = Gift.can_be_sold
      filters.each do |filter|
        @gift_scope = if filter.exclusive_scope?
          @gift_scope.where("gifts.id not in (#{filter.gift_scope.to_sql})")
        else
          @gift_scope.where("gifts.id in (#{filter.gift_scope.to_sql})")
        end
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
        limit #{10 * max_total}
      }
      rows = Gift.connection.select_rows(sql_scores)

      @gift_scores = rows.map do |row|
        {id: row[0].to_i, score: row[1].to_f}
      end
    end

    def sort_gift_scores
      #sorter = Recommender::PostProcessing::CategorySort.new(@gift_scores)
      sorter = Recommender::PostProcessing::DistributedSort.new(@gift_scores)
      @gift_scores = sorter.sort
    end

    def filter_gift_scores
      filter = Recommender::PostProcessing::UniqueProductFilter.new(@gift_scores, max_total)
      @gift_scores = filter.filter
    end

    def generate_recommendations
      @gift_scores.take(max_total).each_with_index do |gift_score, position|
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
