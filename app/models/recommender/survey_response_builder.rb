module Recommender
  class SurveyResponseBuilder
    
    attr_reader :profile, :survey
    
    def initialize(profile, opts = {})
      @profile = profile
      @survey = opts[:survey] || Survey.published.first
    end
    
    def copy!(source)
      SurveyResponse.transaction do
        destination = profile.survey_responses.create!(survey: survey, completed_at: Time.now)
        return merge(source, destination)
      end
    end
  
    def merge!(source, destination)
      @destination_survey_response = destination
      @source_survey_response = source
      
      SurveyResponse.transaction do
        @destination_survey_response = profile.survey_responses.create!(survey: survey, completed_at: Time.now)
        
        @destination_survey_response.question_responses.each do |destination_question_response|
          source_question_response = match_question_response(destination_question_response)
          if source_question_response.present?
            copy_question_response(source_question_response, destination_question_response)
          end
        end
      end
      
      return @destination_survey_response
    end
  
    protected
    
    def match_question_response(target)
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
      question.options.detect do |candidate|
        candidate.id == target.id || candidate.text.to_s == target.text.to_s
      end
    end
  end
end
