class ProfileSetImport

  attr_reader :profile_set, :file, :errors
  
  def initialize profile_set, file
    @profile_set = profile_set
    @file = file
    @questions = {}
    @survey_responses = {}
    @errors = []
  end
  
  def open_file
    if file.present?
      begin
        @xls = Roo::Spreadsheet.open(file)
      rescue Exception
        log_error("Error reading import file")
        return false
      end
    else
      log_error("Import file required")
      return false
    end
    true
  end
  
  def truncate_data
    profile_set.survey_responses.destroy_all
  end

  def insert_data
    # skip header row
    @row_number = 2
    while (@row_number <= @xls.last_row) do
      create_question_response
      @row_number += 1
    end
  end

  def load_question(code)
    @questions[code] ||=
    profile_set.survey.questions.preload(:options).find_by(code: code)
  end

  def load_survey_response(name)
    @survey_responses[name] ||=
    profile_set.survey_responses.preload(:question_responses).find_or_create_by(name: name)
  end

  def create_question_response
    response_name = column_value(1).to_s.strip
    
    if response_name.blank?
      log_error("response name missing")
      return false
    end
    
    survey_response = load_survey_response(response_name)

    if survey_response.blank?
      log_error("survey response not found '#{response_name}'")
      return false
    end

    question_code = column_value(2).to_s.strip
    
    if question_code.blank?
      log_error("question code missing")
      return false
    end

    question = load_question(question_code)
    
    if question.blank?
      log_error("question code not found '#{question_code}'")
      return false
    end
    
    question_response = survey_response.question_responses.find_or_initialize_by(survey_question: question)

    if question_response.survey_question.is_a?(SurveyQuestions::MultipleChoice)
      create_multiple_choice_responses(question_response)
    elsif question_response.survey_question.is_a?(SurveyQuestions::Range)
      question_response.range_response = [[column_value(4).to_f, -1.0].max, 1.0].min
    elsif question_response.survey_question.is_a?(SurveyQuestions::Text)
      question_response.text_response = column_value(3).to_s.strip
    end
    
    question_response.save
      
    true
  end

  def create_multiple_choice_responses(question_response)
    question_response.survey_question_response_options.destroy_all
    
    other_options = []
    column_number = 5
    
    question = question_response.survey_question
    options = question.options.sort_by(&:sort_order)
    
    options.each do |option|
      if option.is_a?(SurveyQuestionOtherOption)
        other_options << option
      else
        selected = column_value(column_number).to_i > 0
        if selected
          question_response.survey_question_response_options.build(survey_question_option: option)
        end
        column_number += 1
      end
    end
    
    # always assign the other option based on the last column
    selected = column_value(column_number).to_i > 0
    
    if selected
      other_options.each do |option|
        question_response.survey_question_response_options.build(survey_question_option: option)
      end
    end
    
    question_response.survey_question_response_options
  end
  
  def column_value(column_number)
    @xls.cell(@row_number, column_number)
  end
  
  def log_error(message)
    if @row_number
      @errors << "#{@row_number}: #{message}"
    else
      @errors << message
    end
  end

end
