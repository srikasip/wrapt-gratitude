class GenerateTraitEvaulationTagMatchesJob < ApplicationJob
  queue_as :default

  attr_accessor :trait_training_set, :survey_response, :evaluation

  def perform(survey_response_trait_evaluation)
    # setup
    @evaluation = survey_response_trait_evaluation
    @trait_training_set = evaluation.trait_training_set
    @survey_response = evaluation.response
    evaluation.matched_tag_ids = {}

    # match tags
    trait_training_set.trait_training_set_questions.each do |trait_training_set_question|
      question = trait_training_set_question.question
      question_response = survey_response.question_responses.where(survey_question_id: question.id).first
      if question_response
        case question
        when SurveyQuestions::MultipleChoice
          tag_id = get_matched_tag_id_for_multiple_choice_question(question_response)
        when SurveyQuestions::Range
          tag_id = get_matched_tag_id_for_range_question(question_response)
        else
          tag_id = nil
        end

        if tag_id
          evaluation.matched_tag_ids[tag_id] ||= 0
          evaluation.matched_tag_ids[tag_id] += 1
        end
      end
    end

    # save
    evaluation.updated_at = Time.now
    evaluation.save

  end

  def get_matched_tag_id_for_multiple_choice_question question_response
    trait_training_set_question = @trait_training_set
      .trait_training_set_questions
      .preload(:trait_response_impacts)
      .detect {|training_question| training_question.question_id == question_response.survey_question_id}
    if trait_training_set_question
      return trait_training_set_question
        .trait_response_impacts
        .detect {|response_impact| response_impact.survey_question_option_id == question_response.survey_question_option_id}
        &.profile_traits_tag_id
    end
  end

  def get_matched_tag_id_for_range_question question_response
    trait_training_set_question = @trait_training_set
      .trait_training_set_questions
      .preload(:trait_response_impacts)
      .detect {|training_question| training_question.question_id == question_response.survey_question_id}
    if trait_training_set_question
      return trait_training_set_question
        .trait_response_impacts
        .detect {|response_impact| (question_reponse.range_response * 3).round == response_impact.range_position}
        &.profile_traits_tag_id
    end
  end


end