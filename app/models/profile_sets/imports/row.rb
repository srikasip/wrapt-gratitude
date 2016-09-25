module ProfileSets
  module Imports
    class Row

      include ActiveModel::Model

      ATTRIBUTE_HEADERS = %w{survey_response_name question_code text_response}
      NUMERIC_HEADERS = %w{numeric_response_1 numeric_response_2 etc}

      attr_accessor *ATTRIBUTE_HEADERS, :numeric_responses
    end
  end
end
