module Recommender
  module Filtering
    class PriceRange < Base
      include ActionView::Helpers::NumberHelper
      
      attr_reader :ranges
      
      def load_params
        @ranges = find_params('price_range') || []
        @ranges = @ranges.select{|r| validate_range(r)}
      end
      
      def description
        if !valid?
          ""
        else
          ranges.map{|r| describe_range(r)}.join(' or ')
        end
      end
      
      def valid?
        ranges.any?
      end
      
      def describe_range(range)
        min_price = range['min_price']
        max_price = range['max_price']
        
        if min_price.present? && max_price.present?
          "price is between #{number_to_currency(min_price)} and #{number_to_currency(max_price)}"
        elsif min_price.present?
          "price is greater than or equal to #{number_to_currency(min_price)}"
        elsif max_price.present?
          "price is less than or equal to #{number_to_currency(max_price)}"
        end
      end
      
      def validate_range(range)
        min_price = range['min_price']
        min_price = min_price.to_f if min_price.present?
          
        max_price = range['max_price']
        max_price = max_price.to_f if max_price.present?
          
        if min_price.present? && min_price < 0
          return false
        elsif max_price.present? && max_price <= 0
          return false
        elsif max_price.present? && min_price.present?
          return max_price > min_price
        elsif max_price.blank? && min_price.blank?
          return false
        end
        
        range['min_price'] = min_price if min_price.present?
        range['max_price'] = max_price if max_price.present?
        
        return true
      end
      
      def gift_scope
        return nil unless valid?
        
        scope = Gift.joins(:calculated_gift_field)

        criteria = arel_criteria_for_range(ranges.first)
        ranges[1..-1].each do |range|
          criteria.or(arel_criteria_for_range(ranges))
        end
        
        scope.select(:id).where(criteria)
      end
      
      def arel_criteria_for_range(range)
        min_price = range['min_price']
        max_price = range['max_price']
        
        cgf = CalculatedGiftField.arel_table
        
        if min_price.present? && max_price.present?
          cgf[:price].between(min_price..max_price)
        elsif min_price.present?
          cgf[:price].gteq(min_price)
        elsif max_price.present?
          cgf[:price].lteq(max_price)
        end
      end
    end
  end
end