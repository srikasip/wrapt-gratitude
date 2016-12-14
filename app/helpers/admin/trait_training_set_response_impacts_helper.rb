module Admin
  module TraitTrainingSetResponseImpactsHelper

    def fields_partial_for_question_type
      case @trait_training_set_question.question
      when SurveyQuestions::MultipleChoice then 'admin/trait_training_set_response_impacts/multiple_choice_fields'
      when SurveyQuestions::Range then 'admin/trait_training_set_response_impacts/range_fields'
      end
    end

    def tag_selected_for_option? tag, option
      @trait_training_set_question.trait_response_impacts.any? do |impact|
       impact.survey_question_option_id == option.id && impact.profile_traits_tag_id == tag.id
      end 
    end

    def tag_selected_for_range_position? tag, range_position
      @trait_training_set_question.trait_response_impacts.any? do |impact|
       impact.range_position == range_position && impact.profile_traits_tag_id == tag.id
      end 
    end

  end
end