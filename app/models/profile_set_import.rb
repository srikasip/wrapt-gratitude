class ProfileSetImport < Import

  importable_name :profile_set, ExcelImportRecordsFileUploader

  def initialize attrs = {}
    super
    @question_scope = profile_set.survey.questions
    @survey_response_scope = profile_set.survey_responses
  end

  def preload!
    sheet.cache_columns_scan!(:survey_response_name, :question_code)
    preload_one!(@survey_response_scope, :survey_response_name, :name, false)
    preload_one!(@question_scope, :question_code, :code, true)
    preload_question_responses!
  end

  def required_headers
    ProfileSets::Imports::Row::ATTRIBUTE_HEADERS + ProfileSets::Imports::Row::MANY_TO_ONE_HEADERS
  end

  def row_record(row)
    survey_response =
      @preloads[@survey_response_scope][row.survey_response_name] ||=
        profile_set.survey_responses.new(name: row.survey_response_name)

    survey_response.skip_build_question_responses_on_create = true

    question = @preloads[@question_scope][row.question_code]

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

  #

  def preload_question_responses!
    @preloads ||= {}

    @preloads[SurveyQuestionResponse] ||=
      SurveyQuestionResponse.
        where(
          survey_response: @preloads[@survey_response_scope].values,
          survey_response_type: 'ProfileSetSurveyResponse',
          survey_question: @preloads[@question_scope].values
        ).
        index_by do |record|
          [record.survey_response_id, record.survey_question_id]
        end
  end
end
