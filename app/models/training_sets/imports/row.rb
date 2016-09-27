module TrainingSets
  module Imports
    class Row

      include ActiveModel::Model

      ATTRIBUTE_HEADERS = %w{gift_sku question_code question_impact}
      MANY_TO_ONE_HEADERS = %w{response_impact_1 response_impact_2 etc.}

      attr_accessor *ATTRIBUTE_HEADERS, :response_impacts

      def many_to_one_values=(values)
        self.response_impacts = values
      end
    end
  end
end
