module Recommender
  class SurveyResponseBuilder
    
    attr_reader :profile, :survey
    
    def initialize(profile, opts = {})
      @profile = profile
      @survey = opts[:survey] || Survey.published.first
    end
    
    def survey_response
      @survey_response || @profile.survey_responses.order('updated_at desc').first
    end
    
    def copy_needed?
      survey_response.blank? ||
      survey_response.survey_id != survey.id ||
      survey_response.recommendations_generated?
    end
    
    def create!
      @survey_response = profile.survey_responses.create!(survey: survey)
    end
        
    def copy!
      SurveyResponse.transaction do
        source = survey_response
        create!
        merge!(source) if source.present?
      end
      return survey_response
    end
  
    def merge!(source)
      @source_survey_response = source
      
      SurveyResponse.transaction do
        survey_response.question_responses.each do |destination_question_response|
          source_question_response = match_question_response(destination_question_response)
          if source_question_response.present?
            copy_question_response(source_question_response, destination_question_response)
          end
        end
      end
      
      return survey_response
    end
    
    def order_question_responses(opts = {})
      unordered= survey_response.question_responses.to_a
      
      prefix = []
      first_codes = Array.wrap(opts[:first])
      first_codes.each do|code|
        question_response = unordered.detect{|_| _.survey_question.code == code}
        prefix << unordered.delete(question_response) if question_response.present?
      end
      
      postfix = []
      last_codes = Array.wrap(opts[:last])
      last_codes.each do|code|
        question_response = unordered.detect{|_| _.survey_question.code == code}
        postfix << unordered.delete(question_response) if question_response.present?
      end
      
      return prefix + unordered + postfix
    end
  
    protected
    
    def match_question_response(target)
      # try to match the question responses based on the question.
      # note: the questions may be from different surveys
      @source_survey_response.question_responses.detect do |candidate|
        (candidate.survey_question.id == target.survey_question.id ||
        candidate.survey_question.code == target.survey_question.code) &&
        (candidate.survey_question.type == target.survey_question.type)
      end
    end
    
    def copy_question_response(source, destination)
      return false if source.unanswered?
      
      case source.survey_question.type
      when 'SurveyQuestions::MultipleChoice'
        copy_multiple_choice_question_response(source, destination)
      when 'SurveyQuestions::Text'
        copy_text_question_response(source, destination)
      when 'SurveyQuestions::Range'
        copy_range_question_response(source, destination)
      end
    end
    
    def copy_text_question_response(source, destination)
      destination.update_attributes(text_response: source.text_response, answered_at: Time.now)
    end
    
    def copy_range_question_response(source, destination)      
      destination.update_attributes(range_response: source.range_response, answered_at: Time.now)
    end
    
    def copy_multiple_choice_question_response(source, destination)
      source.survey_question_response_options.map(&:survey_question_option).each do |source_option|
        destination_option = match_question_option(destination.survey_question, source_option)
        if destination_option.present?
          destination.survey_question_response_options.create(survey_question_option: destination_option)
          destination.update_attributes(answered_at: Time.now) if destination.unanswered?
        end
      end
      return destination.answered?
    end
    
    def match_question_option(question, target)
      # try to match the question option (note: they may be from different surveys)
      question.options.detect do |candidate|
        candidate.id == target.id || candidate.text.to_s == target.text.to_s
      end
    end
  end
end
