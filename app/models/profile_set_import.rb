class ProfileSetImport

  include ActiveModel::Model
  extend CarrierWave::Mount

  REQUIRED_HEADERS = ProfileSets::Imports::Row::ATTRIBUTE_HEADERS + %w{numeric_response_1}

  attr_accessor :profile_set, :question_responses_file

  mount_uploader :question_responses_file, ProfileSetImportResponsesFileUploader

  validates_presence_of :question_responses_file
  validate :presence_of_headers

  def presence_of_headers
    if question_responses_file.present?
      absent_headers = REQUIRED_HEADERS - sheet.header_row
      if absent_headers.any?
        count = absent_headers.count
        errors.add(
          :question_responses_file,
          "#{absent_headers.to_sentence} #{count == 1 ? 'was' : 'were'} "+
            "missing from the header row. Please make sure "+
            "#{count == 1 ? 'it is' : 'they are'} there at the top "+
            "of the proper #{'column'.pluralize(absent_headers.count)}."
        )
      end
    end
  end

  def save_question_responses
    preload!

    questions = @preloads[SurveyQuestion]
    survey_responses = @preloads[ProfileSetSurveyResponse]

    sheet.each do |row|
      question_response = lookup_or_build_question_response(row)
        
      lookup_or_build_survey_response(row).question_responses << question_response
    end

    profile_set.save
  end

  #

  def lookup_or_build_question_response(row)
    survey_response = lookup_or_build_survey_response(row)
    question = @preloads[SurveyQuestion][row.question_code]

    attributes = {text_response: row.text_response}

    if question.is_a? SurveyQuestions::Range
      attributes[:range_response] = row.numeric_responses.first
    end

    if survey_response
      index = [survey_response.id, question.id]

      question_response = @preloads[SurveyQuestionResponse][index]

      question_response.update_attributes(attributes)
      @preloads[SurveyQuestionResponse][index] = question_response
    else
      question_response = question.survey_question_responses.new(attributes)
    end

    if question.is_a? SurveyQuestions::MultipleChoice
      question_response.survey_question_response_options.destroy_all

      options = question.options.order(:sort_order).to_a
      i = 0
      row.numeric_responses.each do |response|
        if response.to_i == 1
          question_response.
            survey_question_response_options.
            new(survey_question_option: options[i])
        end
      end
    end

    question_response
  end

  def lookup_or_build_survey_response(row)
    name = row.survey_response_name
    @preloads[ProfileSetSurveyResponse][name] ||= profile_set.survey_responses.build(name: name)
  end

  def preload!
    sheet.cache_columns_scan!(:survey_response_name, :question_code)
    preload_one!(ProfileSetSurveyResponse, :survey_response_name, :name, false)
    preload_one!(SurveyQuestion, :question_code, :code, true)
    preload_question_responses!
  end

  ##

  def preload_one!(resource_class, column_name, lookup_attr_name, require_existence)
    @preloads ||= {}

    resource = @preloads[resource_class]
    if resource.nil?
      lookups = sheet.cached_columns[column_name]

      resource =
        resource_class.where(lookup_attr_name => lookups).index_by(&lookup_attr_name)

      if require_existence
        missing_lookups = lookups - resource.keys
        if missing_lookups.any?
          exception = ProfileSets::Imports::Exceptions::PreloadsNotFound.new(resource_class, missing_lookups)
          add_exception(exception)
          raise exception
        end
      end
      @preloads[resource_class] = resource
    end
  end

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

  ###

  def add_exception(exception)
    @_exceptions ||= []
    @_exceptions << exception
  end

  def sheet
    @_sheet ||= ProfileSets::Imports::Sheet.new(question_responses_file)
  end
end
