class MyAccount::GifteesController < MyAccount::BaseController
  include PjaxModalController

  helper :address

  before_action :_load_giftee, only: [:edit, :update]

  def index
    @giftees = current_user.owned_profiles.page(params[:page])
  end

  def edit
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
    params.require(:profile).permit(:first_name, :last_name, :email, :attributes_for_address => [:id, :street1, :city, :state, :zip])
  end
end
