module TrainingSets
  module Imports
    class Row

      include ActiveModel::Model

      ATTRIBUTE_HEADERS = %w{gift_sku question_code question_impact slider_impact_direction}
      MANY_TO_ONE_HEADERS = 10.times.map {|number| "choice_#{number + 1}_impact"}

      attr_accessor *ATTRIBUTE_HEADERS, :response_impacts

      def many_to_one_values=(values)
        self.response_impacts = values
      end
    end
  end
end
