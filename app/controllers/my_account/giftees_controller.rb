class MyAccount::GifteesController < MyAccount::BaseController
  helper :address

  def index
    @giftees = current_user.owned_profiles.page(params[:page])
  end

  def show
    @giftee = current_user.owned_profiles.find(params[:id])
  end
end
