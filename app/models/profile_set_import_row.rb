class ProfileSetImportRow

  include ActiveModel::Model

  ATTRIBUTE_HEADERS = %w{survey_response_name question_code text_response}
  NUMERIC_COLUMN_START = ATTRIBUTE_HEADERS.count

  attr_accessor *ATTRIBUTE_HEADERS, :numeric_responses

  def self.init_by_array(header_order, row_array)
    row = new(header_order.zip(row_array).to_h)
    row.numeric_responses = row_array[NUMERIC_COLUMN_START..100].compact
    row
  end

  def save_question_response
    SurveyQuestion.where(code: question_code).all
  end
end
