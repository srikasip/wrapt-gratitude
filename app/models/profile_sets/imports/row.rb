module ProfileSets
  module Imports
    class Row

      include ActiveModel::Model

      ATTRIBUTE_HEADERS = %w{
        survey_response_name
        question_code
        text_response
        slider_response
      }

      MANY_TO_ONE_HEADERS = 10.times.map {|number| "choice_#{number + 1}"}

      REQUIRED_RESPONSES_FOR_TYPE = {
        'SurveyQuestions::Text' => :text_response,
        'SurveyQuestions::Range' => :slider_response,
        'SurveyQuestions::MultipleChoice' => :numeric_responses
      }

      attr_accessor *ATTRIBUTE_HEADERS, :numeric_responses, :row_number
      
      def question_code
        @question_code.to_s.strip
      end

      def survey_response_name
        @survey_response_name.to_s.strip
      end

      validate :having_one_or_zero_of_present_choices

      validates_numericality_of :slider_response,
        if: 'slider_response.present?',
        greater_than_or_equal_to: -1.0,
        less_than_or_equal_to: 1.0

      validates_presence_of :survey_response_name, :question_code

      def having_one_or_zero_of_present_choices
        non_booleans = numeric_responses.map.with_index(1) do |response, index|
          response.present? && !response.to_i.in?([1, 0]) && [index, response]
        end.select(&:itself).to_h

        if non_booleans.any?
          errors.add(
            non_booleans.keys.map {|number| "choice_#{number}"}.join(', '),
            "all present values must be a '0' or a '1'"
          )
        end
      end

      def many_to_one_values=(values)
        self.numeric_responses = values
      end
    end
  end
end
