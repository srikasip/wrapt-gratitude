class SurveyCopyingJob < ApplicationJob

  attr_reader :source_survey, :target_survey

  def perform source_survey, target_survey
    @source_survey = source_survey
    @target_survey = target_survey
    @question_mapping = {}
    copy_questions!
    copy_question_options!
  ensure
    @target_survey.update! copy_in_progress: false
    ActionCable.server.broadcast "survey_copyings", html: render_survey(target_survey), survey_id: target_survey.id
  end

  private def copy_questions!
    source_survey.questions.each do |source_question|
      target_question = target_survey.questions.create question_attributes_to_copy(source_question)
      @question_mapping[source_question.id] = target_question.id
    end
  end

  private def question_attributes_to_copy source_question
    source_question.attributes.reject {|k, v| k =~ /^(id|created_at|updated_at|survey_id)$/}
  end
  
  private def copy_question_options!
    source_survey.questions.each do |source_question|
      source_question.options.each do |source_option|
        target_option = SurveyQuestionOption.new option_attributes_to_copy(source_option)
        target_option.survey_question_id = @question_mapping[source_question.id]
        copy_option_image source_option, target_option
        target_option.save
      end
    end
  end

  private def option_attributes_to_copy source_option
    source_option.attributes.reject {|k, v| k =~ /^(id|created_at|updated_at|survey_question_id|image)/}
  end

  private def copy_option_image source_option, target_option
    target_option.remote_image_url = source_option.image.url
  end
  
  private def render_survey survey
    ApplicationController.renderer.render partial: 'surveys/survey', locals: {survey: survey}
  end
      
  

end