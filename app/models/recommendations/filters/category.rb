module Recommendations
  module Filters
    class Category < Base

      def applied?
        included_codes.any? || excluded_codes.any?
      end
      
      def included_codes
        codes_from_params('include_codes')
      end
      
      def excluded_codes
        codes_from_params('exclude_codes')
      end
      
      def name
        "Category"
      end
      
      def description
        inclusion_description = if included_codes.any?
          "include gifts with a category code of #{included_codes.to_sentence(last_word_connector: ' or ')}."
        else
          nil
        end

        exclusion_description = if excluded_codes.any?
          "exclude gifts with a category code of #{excluded_codes.to_sentence(last_word_connector: ' or ')}"
        else
          nil
        end
  
        ret = [inclusion_description, exclusion_description].compact.join(' but ')
        ret[0] = ret[0].upcase
        ret
      end
      
      
      def apply(recommendations)
        ret = []
        ret += recommendations.select do |recommendation|
          has_category_code?(recommendation.gift, included_codes)
        end
        ret += recommendations.reject do |recommendation|
          has_category_code?(recommendation.gift, excluded_codes)
        end
        ret
      end
            
      protected
      
      def has_category_code?(gift, codes)
        codes.include?(gift&.product_category&.wrapt_sku_code.to_s)
      end
      
      def codes_from_params(param_name)
        ret = []
        if question_response.present?
          question_response.survey_question_options.each do |options|
            codes = Array.wrap(options.configuration_params[param_name])
            ret += codes.map{|code| code.to_s.strip.upcase}.select(&:present?)
          end
        end
        ret.uniq
      end
    end
  end
end