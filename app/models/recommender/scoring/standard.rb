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
      
      def description
        "add #{@featured_boost} if featured"
      end
      
      def scoring_sql
        %{
          select id,
            case
            when featured then #{featured_boost.to_i}
            else 0
            end as score
          from gifts
          where id in (#{engine.gift_scope.select(:id).to_sql})
        }
      end
    end
  end
end