module ProfileSets
  module Imports
    class Row

      include ActiveModel::Model

      ATTRIBUTE_HEADERS = %w{survey_response_name question_code text_response slider_response}
      MANY_TO_ONE_HEADERS = 10.times.map {|number| "choice_#{number + 1}"}

      attr_accessor *ATTRIBUTE_HEADERS, :numeric_responses

      def many_to_one_values=(values)
        self.numeric_responses = values
      end
    end
  end
end
