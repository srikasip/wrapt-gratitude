module Recommender
  module Filtering
    class Price
      attr_reader :min_price, :max_price
      
      def gift_scope
        if min_price.present? && max_price.present?
        elsif min_price.present?
        elsif max_price.present?
        else
          nil
        end
      end
    end
  end
end