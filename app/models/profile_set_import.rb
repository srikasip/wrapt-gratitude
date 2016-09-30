class ProfileSetImport < Import

  importable_name :profile_set, ExcelImportRecordsFileUploader

  def preload!
    sheet.cache_columns_scan!(:survey_response_name, :question_code)
    preload_one!(ProfileSetSurveyResponse, :survey_response_name, :name, false)
    preload_one!(SurveyQuestion, :question_code, :code, true)
    preload_question_responses!
  end

  def required_headers
    ProfileSets::Imports::Row::ATTRIBUTE_HEADERS + ProfileSets::Imports::Row::MANY_TO_ONE_HEADERS
  end

  def row_record(row)
    survey_response =
      @preloads[ProfileSetSurveyResponse][row.survey_response_name] ||=
        profile_set.survey_responses.new(name: row.survey_response_name)

    question = @preloads[SurveyQuestion][row.question_code]

    question_response =
      @preloads[SurveyQuestionResponse][[survey_response.id, question.id]] ||
      survey_response.question_responses.new(survey_question: question)

    conversion = ProfileSets::Imports::Conversion.new(row)

    question_response.text_response = conversion.text_response
    question_response.range_response = conversion.range_response(question)

    question_response.survey_question_response_options.destroy_all
    question_response.survey_question_response_options = conversion.survey_question_response_options(question)

    question_response
  end

  def validity_of_row(row)
    super

    type = @preloads[SurveyQuestion][row.question_code].try(:type)
    if type
      response_attribute = ProfileSets::Imports::Row::REQUIRED_RESPONSES_FOR_TYPE[type]

      if response_attribute == :numeric_responses
        if row.numeric_responses.none? {|response| response == 1}
          headers = ProfileSets::Imports::Row::MANY_TO_ONE_HEADERS
          @row_errors[row.row_number] ||= {}
          @row_errors[row.row_number][headers] ||= []
          @row_errors[row.row_number][headers] << "one of them must have a '1'"
        end
      elsif !row.send(response_attribute).present?
        @row_errors[row.row_number] ||= {}
        @row_errors[row.row_number][response_attribute] ||= []
        @row_errors[row.row_number][response_attribute] << "can't be blank"
      end
    end
  end

  #

  def preload_question_responses!
    @preloads ||= {}

    @preloads[SurveyQuestionResponse] ||=
      SurveyQuestionResponse.
        where(
          survey_response: @preloads[ProfileSetSurveyResponse].values,
          survey_question: @preloads[SurveyQuestion].values
        ).
        index_by do |record|
          [record.profile_set_survey_response_id, record.survey_question_id]
        end
  end
end
