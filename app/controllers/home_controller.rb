class HomeController < ApplicationController
  include FeatureFlagsHelper

  helper HeroBackgroundHelper
  helper CarouselHelper
  helper FeatureFlagsHelper
  helper SurveyQuestionResponsesHelper

  def show
    if current_user && current_user.last_viewed_profile.present?
      if session[:last_completed_survey_at].present?
        completed_at = session[:last_completed_survey_at]
        session.delete(:last_completed_survey_at)

        if (Time.now - completed_at) < 10.minutes
          redirect_to giftee_gift_recommendations_path(current_user.last_viewed_profile) and return
        end
      end
    end

    if !require_invites? || current_user.present?
      @survey ||= Survey.published.first
      first_question = if @survey.sections.any?
        @survey.sections.first.questions.first
      else
        @survey.questions.first
      end
      @question_response = SurveyQuestionResponse.new survey_question: first_question
    end
  end

  def loop11_enabled?
    false
  end

  private def login_required?
    false
  end

end
