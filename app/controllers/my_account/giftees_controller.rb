class MyAccount::GifteesController < MyAccount::BaseController
  include PjaxModalController

  helper :address
  helper :survey_question_responses

  before_action :_load_giftee, only: [:edit, :update]

  def new
    @survey ||= Survey.published.first
    first_question = if @survey.sections.any?
      @survey.sections.first.questions.first
    else
      @survey.questions.first
    end
    @question_response = SurveyQuestionResponse.new survey_question: first_question
  end

  def index
    @giftees = current_user.owned_profiles.preload(gift_recommendation_sets: :recommendations).unarchived.well_ordered.page(params[:page])
  end

  def edit
    @giftee.address || @giftee.build_address
  end

  def update
    @giftee.assign_attributes(_permitted_attributes)

    if @giftee.save
      redirect_to action: :index
    else
      flash.now[:error] = 'There was a problem saving. Please correct the errors below'
      render :edit
    end
  end

  private

  def _load_giftee
    @giftee = current_user.owned_profiles.find(params[:id])
  end

  def _permitted_attributes
    params.require(:profile).permit(:name, :first_name, :last_name, :email, :birthday_day, :birthday_month, :birthday_year, :address_attributes => [:id, :street1, :city, :state, :zip])
  end
end
