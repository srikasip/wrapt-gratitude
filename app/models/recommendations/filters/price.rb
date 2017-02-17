module Recommendations
  module Filters
    class Price < Base
      
      def ranges
        ret = []
        if question_response.present?
          question_response.survey_question_options.each do |options|
            params = options.configuration_params.slice('min_price', 'max_price')
            if params.any?
              ret << params
            end
          end
        end
        ret
      end
      
      def name
        "Price"
      end
      
      def description
        range_descriptions = ranges.map{|r| range_description(r['min_price'], r['max_price'])}
        range_descriptions.map!{|d| "(#{d})"} if range_descriptions.many?
        "Include gifts where the price is: #{range_descriptions.join(' or ')}"
      end
      
      def range_description(min_price, max_price)
        if min_price.present? && max_price.present?
          "between #{number_to_currency(min_price.to_f)} and #{number_to_currency(max_price.to_f)}"
        elsif min_price.present?
          "greater than or equal to #{number_to_currency(min_price.to_f)}"
        elsif max_price.present?
          "less than or equal to #{number_to_currency(max_price.to_f)}"
        else
          ''
        end
      end
      
      def apply(recommendations)
        ret = []
        ranges.each do |range|
          ret += apply_price_filter(recommendations, range['min_price'], range['max_price'])
        end
        ret
      end
      
      def apply_price_filter(recommendations, min_price, max_price)
        if min_price.present? && max_price.present?
          recommendations.select{|r| r.gift.selling_price.to_f <= max_price.to_f && r.gift.selling_price.to_f >= min_price.to_f}
        elsif min_price.present?
          recommendations.select{|r| r.gift.selling_price.to_f >= min_price.to_f}
        elsif max_price.present?
          recommendations.select{|r| r.gift.selling_price.to_f <= max_price.to_f}
        else
          recommendations
        end
      end

    end
  end
end