class Ecommerce::CheckoutController < ApplicationController
  before_action -> { redirect_to :root }, if: -> { ENV.fetch('CHECKOUT_ENABLED') { 'false' } == 'false' }

  before_action :_load_service_object, except: [:edit_gift_wrapt]

  def edit_gift_wrapt
    @checkout_step = :gift_wrapt

    flash.now[:notice] = <<~EOS
      You're getting a new shopping cart each time you visit this page. Todd
      needs to know how completed orders and multiple profiles all interact
      with respect to your shopping cart being cleared out.
    EOS

    session[:cart_id] = SecureRandom.hex(16)

    profile = current_user.owned_profiles.find params[:profile_id]

    desired_gifts = profile.gift_selections.map do |gs|
      ::DesiredGift.new(gs.gift, 1)
    end

    @customer_purchase = ::CustomerPurchase.new({
      cart_id: session[:cart_id],
      customer: current_user,
      desired_gifts: desired_gifts,
      profile: profile,
    })

    @customer_order = @customer_purchase.generate_order!
  end

  def save_gift_wrapt
    @checkout_step = :gift_wrapt
    if @customer_purchase.gift_wrapt!(params)
      redirect_to action: :edit_address
    else
      flash.now[:notice] = "There was a problem saving your response."
      render :edit_gift_wrapt
    end
  end

  def edit_address
    @checkout_step = :shipping
  end

  def save_address
    @checkout_step = :shipping
    @customer_purchase.set_address!(params)

    if @customer_purchase.things_look_shipable?
      redirect_to action: :edit_shipping
    else
      flash.now[:notice] = "Please make sure you've specified an address to continue."
      render :edit_address
    end
  end

  def edit_shipping
    flash.now[:notice] = "Always pick USPS while we're developing a solution to reconciling shippo choices across all purchase orders"
    @checkout_step = :shipping
    @shipping_choices = @customer_purchase.shipping_choices_for_view
  end

  def save_shipping
    @checkout_step = :shipping

    if @customer_purchase.pick_shipping!(params.dig(:customer_order, :shippo_token_choice))
      redirect_to action: :edit_payment
    else
      flash.now[:notice] = "There was a problem saving your response."
      @shipping_choices = @customer_purchase.shipping_choices_for_view
      render :edit_shipping
    end
  end

  def edit_payment
    @checkout_step = :payment
  end

  def save_payment
    if @customer_purchase.init_our_charge_record!(params[:stripeToken])
      redirect_to action: :edit_review
    else
      flash.now[:notice] = "There was a problem saving your response."
      render :edit_payment
    end

    @checkout_step = :payment
  end

  def edit_review
    @checkout_step = :review
  end

  def save_review
    @checkout_step = :review

    if @customer_purchase.authorize!
      redirect_to action: :finalize
    else
      # Shouldn't ever happen
      flash.now[:notice] = "There was a problem saving your response."
      render :edit_review
    end
  end

  def finalize
    @checkout_step = :finalize
  end

  private

  def _load_service_object
    @customer_purchase = ::CustomerPurchase.new(cart_id: session[:cart_id])
    @customer_order = @customer_purchase.customer_order
    @profile = @customer_order.profile
  end
end
