class ProfilesController < ApplicationController

  include RequiresLoginOrInvitation

  def new
    @profile = current_user.owned_profiles.new
  end

  def create
    @profile = current_user.owned_profiles.new profile_params
    if @profile.save
      # TODO go somewhere for real
      survey_response = @profile.survey_responses.create survey: Survey.published.first
      redirect_to with_invitation_scope(profile_survey_question_path(@profile, survey_response, survey_response.ordered_question_responses.first))
    else
      render :new
    end
  end

  private def login_via_invitation_code
    if params[:invitation_id] && !current_user
      user = User.load_from_activation_token params[:invitation_id]
      auto_login(user) if user
    end
  end

  private def profile_params
    result = {}
    if params[:commit].in? Profile::RELATIONSHIPS
      result[:relationship] = params[:commit]
    end
    result
  end

end
