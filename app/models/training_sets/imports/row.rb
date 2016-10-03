module TrainingSets
  module Imports
    class Row

      include ActiveModel::Model

      ATTRIBUTE_HEADERS = %w{
        gift_sku
        question_code
        question_impact
        slider_impact_direction
      }
      
      MANY_TO_ONE_HEADERS = 10.times.map {|number| "choice_#{number + 1}_impact"}

      attr_accessor *ATTRIBUTE_HEADERS, :response_impacts, :row_number

      validates_presence_of :gift_sku, :question_code, :question_impact

      def gift_sku
        @gift_sku.to_s.strip
      end

      def survey_response_name
        @survey_response_name.to_s.strip
      end

      def many_to_one_values=(values)
        self.response_impacts = values
      end
    end
  end
end
