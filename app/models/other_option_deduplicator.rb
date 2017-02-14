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

        if training_set_merge_conflicts? option, option_to_keep
          puts "CONFLICT: survey##{question.survey_id} / question##{question.id} / option##{option.id} => #{option_to_keep.id} / training_set_response_impacts"
          next
        end

        if trait_merge_conflicts? option, option_to_keep
          puts "CONFLICT: survey##{question.survey_id} / question##{question.id} / option##{option.id} => #{option_to_keep.id} / trait_response_impacts"
          next 
        end

        # TODO dedupe non-conflicting impacts
        unless @test_mode 
          option.training_set_response_impacts.update_all survey_question_option_id: option_to_keep.id
          option.trait_response_impacts.update_all survey_question_option_id: option_to_keep.id
          option.survey_question_response_options.update_all survey_question_option_id: option_to_keep.id
          option.conditional_question_options.update_all survey_question_option_id: option_to_keep.id

          option.delete
        end



        puts "MERGED: survey##{question.survey_id} / question##{question.id} / option##{option.id} => #{option_to_keep.id}"


      end
    end
  end

  private def training_set_merge_conflicts? option, other_option
    option.training_set_response_impacts.each do |impact|
      other_impacts = other_option.training_set_response_impacts.where(gift_question_impact_id: impact.gift_question_impact_id)
      other_impacts.each do |other_impact|
        return true if impact.impact != other_impact.impact
      end      
    end
    return false
  end
  
  private def trait_merge_conflicts? option, other_option
    option.trait_response_impacts.each do |impact|
      other_impacts = other_option.trait_response_impacts.where(trait_training_set_question_id: impact.trait_training_set_question_id)
      other_impacts.each do |other_impact|
        return true if impact.profile_traits_tag_id != other_impact.profile_traits_tag_id
      end
    end
    return false
  end

end