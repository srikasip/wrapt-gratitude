class HomeController < ApplicationController
  include FeatureFlagsHelper

  helper HeroBackgroundHelper
  helper CarouselHelper
  helper FeatureFlagsHelper
  helper SurveyQuestionResponsesHelper

  def show
    if current_user && current_user.last_viewed_profile.present? && !current_user.admin?
      redirect_to profile_gift_recommendations_path(current_user.last_viewed_profile) and return
    end

    unless current_user&.admin?
      @invitation_request = InvitationRequest.new
    end

    if not require_invites?
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
