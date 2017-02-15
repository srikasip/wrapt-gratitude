class OtherOptionDeduplicator
  
  def initialize **options
    @test_mode = options[:test_mode]
  end

  def run!
    SurveyQuestions::MultipleChoice.all.each do |question|
      other_options = question.options.where(type: 'SurveyQuestionOtherOption')

      next unless other_options.length > 1

      option_to_keep = other_options.first
      other_options[1..-1].each do |option|

        merge_training_set_response_impacts option_to_keep, option
        merge_trait_response_impacts option_to_keep, option

        unless @test_mode
          option.survey_question_response_options.update_all survey_question_option_id: option_to_keep.id
          option.conditional_question_options.update_all survey_question_option_id: option_to_keep.id

          option.delete
        end



        puts "MERGED: survey##{question.survey_id} / question##{question.id} / option##{option.id} => #{option_to_keep.id}"


      end
    end
  end

  private def merge_training_set_response_impacts target, source
    # merges training_set_response_impacts from source into target
    # in case of a collision, the target's impact is preserved
    question = source.question
    source.training_set_response_impacts.each do |impact|
      if target.training_set_response_impacts.where(gift_question_impact_id: impact.gift_question_impact_id).exists?
        puts "DELETED: survey##{question.survey_id} / question##{question.id} / option##{source.id} / training_set_response_impact##{impact.id}"
        impact.destroy unless @test_mode
      else
        impact.update survey_question_option_id: target.id unless @test_mode
        puts "COPITED: survey##{question.survey_id} / question##{question.id} / option##{option.id} => #{target.id} / training_set_response_impact##{impact.id}"
      end
    end
  end

  private def merge_trait_response_impacts target, source
    # merges trait_response_impacts from source into target
    # in case of a collision, the target's impact is preserved
    question = source.question
    source.trait_response_impacts.each do |impact|
      if target.trait_response_impacts.where(trait_training_set_question_id: impact.trait_training_set_question_id).exists?
        puts "DELETED: survey##{question.survey_id} / question##{question.id} / option##{source.id} / trait_response_impact##{impact.id}"
        impact.destroy unless @test_mode
      else
        puts "COPITED: survey##{question.survey_id} / question##{question.id} / option##{option.id} => #{target.id} / trait_response_impact##{impact.id}"
        impact.update survey_question_option_id: target.id unless @test_mode
      end
    end
  end

end