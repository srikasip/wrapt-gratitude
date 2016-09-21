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
    survey_responses = @preloads[SurveyResponse]

    sheet.each do |row|
      question_response = questions[row.question_code].survey_question_responses.new
      lookup_or_build_survey_response(row.survey_response_name) << question_response
    end

    profile_set.save
  end

  def lookup_or_build_survey_response(name)
    if !@preloads[SurveyResponse][name]
      @preloads[SurveyResponse][name] = profile_set.survey_responses.build(name: name)
    end
  end

  #

  def preload!
    sheet.cache_columns_scan!(:survey_response_name, :question_code)
    preload_one!(SurveyQuestionResponse, :survey_response_name, :name, false)
    preload_one!(SurveyQuestion, :question_code, :code, true)
  end

  ##

  def preload_one!(resource_class, column_name, lookup_attr_name, require_existence)
    @preloads ||= {}

    resource = @preloads[resource_class]
    if @preloads[resource_class].nil?
      lookups = sheet.cached_columns[column_name]

      @preloads[resource_class] =
        resource_class.where(lookup_attr_name => lookups).index_by(&lookup_attr_name.to_sym)

      if require_existence
        missing_lookups = lookups - @preloads[resource_class].keys
        if missing_lookups.any?
          exception = ProfileSets::Imports::Exceptions::PreloadsNotFound.new(lookup_attr_name, missing_lookups)
          add_exception(exception)
          raise exception
        end
      end
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
