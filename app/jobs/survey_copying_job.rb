class SurveyCopyingJob < ApplicationJob

  attr_reader :source_survey, :target_survey

  def perform source_survey, target_survey
    if target_survey.questions.count > 0
      Rails.logger.fatal "Refusing to process target survey #{target_survey.id}: It already has questions."
      return
    end

    @source_survey = source_survey
    @target_survey = target_survey
    @question_mapping = {}
    Survey.transaction do
      copy_questions!
      copy_question_options!
      target_survey.update!(copy_in_progress: false)
    end
  ensure
    begin
      ActionCable.server.broadcast "survey_copyings", html: render_survey(target_survey), survey_id: target_survey.id
    rescue Exception => e
      Rails.logger.fatal "Failed to broadcast about survey #{target_survey.id}: #{e.message}"
    end
  end

  private def copy_questions!
    source_survey.questions.each do |source_question|
      target_question = target_survey.questions.new question_attributes_to_copy(source_question)

      target_section = SurveySection.where(survey: target_survey, name: source_question.survey_section.name).first_or_initialize
      target_section.save!

      target_question.survey_section = target_section

      # Avoids duplicate "Other option" option and having it as the first option
      if target_question.is_a?(SurveyQuestions::MultipleChoice)
        target_question.skip_other_option_handling = true
      end

      target_question.save!

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
        target_option.save!
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
    ApplicationController.renderer.render partial: 'admin/surveys/survey', locals: {survey: survey}
  end

end
