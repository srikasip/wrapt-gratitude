module Recommender
  module Filtering
    class PriceRange
      attr_reader :min_price, :max_price
      
      def load_params
        @min_price = nil
        @max_price = nil
        params = find_params('price_range').first
        if params.present?
          @min_price = params['min_price'].to_f if params.has_key?('min_price')
          @max_price = params['max_price'].to_f if params.has_key?('max_price')
        end
      end
      
      def valid?
        if min_price.present? && min_price < 0
          false
        elsif max_price.present? && max_price <= 0
          false
        elsif max_price.present? && min_price.present?
          max_price > min_price
        elsif max_price.blank? && min_price.blank?
          false
        else
          true
        end
      end
      
      def gift_scope
        return nil unless valid?
        cgf = CalculatedGiftField.arel_table
        scope = Gift.joins(:gift_prices)
        if min_price.present? && max_price.present?
          scope = scope.where(cgf[:price].between(min_price..max_price))
        elsif min_price.present?
          scope = scope.where(cgf[:price].gteq(min_price))
        elsif max_price.present?
          scope = scope.where(cgf[:price].lteq(max_price))
        end
        scope
      end
    end
  end
end