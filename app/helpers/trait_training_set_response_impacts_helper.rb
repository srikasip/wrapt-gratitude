module TraitTrainingSetResponseImpactsHelper

  def tag_selected_for_option? tag, option
    @trait_training_set_question.trait_response_impacts.any? do |impact|
     impact.survey_question_option_id == option.id && impact.profile_traits_tag_id == tag.id
    end 
  end



end