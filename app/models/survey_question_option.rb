class SurveyQuestionOption < ApplicationRecord
  belongs_to :question, class_name: 'SurveyQuestion', inverse_of: :options, foreign_key: :survey_question_id
  mount_uploader :image, SurveyQuestionOptionImageUploader

  # unused relationships but they're here to clean up foreign keys
  has_many :survey_question_response_options, dependent: :destroy
  has_many :conditional_question_options, dependent: :destroy
  
  validate :validate_configuration_string_format

  before_create :set_initial_sort_order

  scope :standard, -> {where type: ['SurveyQuestionOption', nil]}

  private def set_initial_sort_order
    next_sort_order = ( question&.options&.maximum(:sort_order) || 0 ) + 1
    self.sort_order = next_sort_order
  end
  
  def configuration_params
    @_configuration_params_cache ||= {}
    @_configuration_params_cache[configuration_string.to_s] ||= parse_configuration_params
  end
  
  def validate_configuration_string_format
    begin
      parse_configuration_params!
    rescue JSON::ParserError
      errors.add(:configuration_string, "Invalid format")
    end
  end
  
  def parse_configuration_params
    ret = {}
    begin
      ret = parse_configuration_params!
    rescue JSON::ParserError
    end
    ret
  end

  def parse_configuration_params!
    ActiveSupport::JSON.decode("{#{configuration_string}}")
  end

end
