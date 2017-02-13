class TrainingSetImport
  
  attr_reader :training_set, :file, :errors
  
  def initialize training_set, file
    @training_set = training_set
    @file = file
    @questions = {}
    @gifts = {}
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
    training_set.gift_question_impacts.destroy_all
  end
  
  def insert_data
    # skip header row
    @row_number = 2
    while (@row_number <= @xls.last_row) do
      create_question_impact
      @row_number += 1
    end
  end
  
  def load_question(code)
    @questions[code] ||= training_set.survey.questions.preload(:options).find_by(code: code)
  end

  def load_gift(sku)
    @gifts[sku] ||= Gift.find_by(wrapt_sku: sku)
  end
  
  def create_question_impact
    gift_sku = column_value(1).to_s.strip
    
    if gift_sku.blank?
      log_error("gift sku missing")
      return false
    end
    
    gift = load_gift(gift_sku)

    if gift.blank?
      log_error("gift sku not found '#{gift_sku}'")
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
    
    question_impact = training_set.gift_question_impacts.find_or_initialize_by(gift: gift, survey_question: question)

    question_impact.question_impact = [[column_value(3).to_f, 0.0].max, 1.0].min
    question_impact.range_impact_direct_correlation = column_value(4).to_i >= 0
    
    question_impact.save
    
    create_response_impacts(question_impact)
    
    true
  end
  
  def create_response_impacts(question_impact)
    question_impact.response_impacts.destroy_all
    if question_impact.survey_question.is_a?(SurveyQuestions::MultipleChoice)
      question_impact.survey_question.options.each_with_index do |option, n|
        impact = [[column_value(5 + n).to_f, -1.0].max, 1.0].min
        question_impact.response_impacts.create(survey_question_option: option, impact: impact)
      end
    end
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
