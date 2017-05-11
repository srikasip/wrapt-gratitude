module Recommender
  module Scoring
    class Standard < Base
      attr_reader :featured_boost
      
      def load_params
        @featured_boost = 1
      end
      
      def valid?
        true
      end
      
      def scoring_sql
        %{
          select id,
            case
            when featured then #{featured_boost}
            else 0
            end as score
          from gifts
          where id in (#{engine.gift_scope.select(:id).to_sql})
        }
      end
    end
  end
end