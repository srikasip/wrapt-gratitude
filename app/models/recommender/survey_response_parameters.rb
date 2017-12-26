module Recommender
  module SurveyResponseParameters
    def find_params(name)
      params = []
      engine.question_responses.each do |response|
        response.survey_question_options.each do |option|
          option_param = option.configuration_params[name.to_s]
          params << option_param if option_param.present?
        end
      end
      params
    end

    def collect_tag_names(params)
      tag_names = []
      Array.wrap(params).each do |param_tag_names|
        tag_names += sanitize_tag_names(param_tag_names)
      end
      tag_names.uniq
    end
    
    def sanitize_tag_names(tag_names)
      Array.wrap(tag_names).map do |tag_name|
        tag_name.to_s.strip
      end.select do |tag_name|
        tag_name =~ Gift::VALID_TAG_REGEXP
      end.uniq
    end
  end
end