module Recommender
  module TagBoost
    class Standard < Base
      attr_reader :boost
      
      def load_params
        @boost = 1
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