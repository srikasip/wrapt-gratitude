class Ecommerce::CheckoutController < ApplicationController
  include PjaxModalController
  include AddressHelper
  include FeatureFlagsHelper

  before_action -> { redirect_to :root }, unless: -> { checkout_enabled? }
  before_action :_load_service_object, except: [:start]
  before_action -> { @enable_chat = true }
  before_action :include_enhanced_ecommerce_analytics
  before_action :load_enhanced_analytics_data, only: [:edit_gift_wrapt, :edit_giftee_name, :edit_address, :edit_payment, :edit_review, :finalize]

  helper :orders

  def start
    profile = current_user.owned_profiles.find(params[:giftee_id])

    customer_purchase = Ec::PurchaseService.find_existing_cart_or_initialize(profile: profile, user: current_user)

    customer_purchase.generate_order!

    session[:cart_id] = customer_purchase.cart_id

    redirect_to action: :edit_gift_wrapt
  end

  def edit_gift_wrapt
    @load_in_modal = pjax_request?
    @checkout_step = :gift_wrapt
    _load_progress_bar
  end

  def save_gift_wrapt
    @checkout_step = :gift_wrapt
    if @customer_purchase.gift_wrapt!(params)
      if pjax_request?
        # loads in modal on order review page
        redirect_to action: :edit_review
      else
        redirect_to action: :edit_giftee_name
      end
    else
      flash.now[:notice] = "There was a problem saving your response."
      _load_progress_bar
      render :edit_gift_wrapt
    end
  end

  def edit_giftee_name
    @checkout_step = :shipping
    _load_progress_bar
  end

  def save_giftee_name
    @checkout_step = :shipping
    if @customer_purchase.set_giftee_name!(params)
      redirect_to action: :edit_address
    else
      flash.now[:notice] = "There was a problem saving your response."
      _load_progress_bar
      render :edit_giftee_name
    end
  end

  def edit_address
    @checkout_step = :shipping
    _load_addresses
    _load_progress_bar
  end

  def save_address
    @checkout_step = :shipping
    @customer_purchase.set_address!(params)
    @customer_purchase.pick_shipping!('cheapest')

    if @customer_purchase.things_look_shipable?
      redirect_to action: :edit_payment
    else
      error_message = @customer_purchase.customer_order.errors.full_messages.join('. ')
      flash.now[:notice] = "Please make sure you've specified an address to continue. #{error_message}"
      _load_addresses
      _load_progress_bar
      render :edit_address
    end
  end

  def edit_payment
    @checkout_step = :payment
    _load_progress_bar
  end

  def save_payment
    @promo_code = params[:promo_code]
    if @promo_code.present?
      _add_promo!
    end
    if @promo_error_message.present?
      @checkout_step = :payment
      _load_progress_bar
      render :edit_payment
    else
      if @customer_purchase.init_our_charge_record!(params)
        redirect_to action: :edit_review
      else
        flash.now[:notice] = "There was a problem saving your response."
        @checkout_step = :payment
        _load_progress_bar
        render :edit_payment
      end
    end
  end

  def edit_review
    @checkout_step = :review

    if @customer_purchase.need_shipping_calculated
      @shipping_recalculated = true
      @customer_purchase.update_order_totals!
    end
    _load_progress_bar
  end

  def save_review
    @checkout_step = :review

    @customer_purchase.authorize!

    if @customer_purchase.card_authorized?
      redirect_to action: :finalize
    else
      flash[:notice] = "There was a problem authorizing your card. Please try again."
      redirect_to action: :edit_payment
    end
  end

  def finalize
    @include_finalize_adwords_script = true
    @checkout_step = :finalize
    @expected_delivery = @customer_purchase.expected_delivery.text
  end

  private

  def load_enhanced_analytics_data 
    step_options = {
      edit_gift_wrapt: {option: 'Checkout 1: Note', step: 1},
      edit_giftee_name: {option: 'Checkout 2: Shipping: Giftee Name', step: 2},
      edit_address: {option: 'Checkout 3: Shipping: Address', step: 3},
      edit_payment: {option: 'Checkout 4: Payment Info', step: 4},
      edit_review: {option: 'Checkout 5: Review Details', step: 5},
      finalize: {id: @customer_order.id},
      customer_order_details: {
        tax: @customer_order.taxes_in_dollars,
        shipping: @customer_order.combined_handling_in_dollars,
        revenue: @customer_order.total_to_charge_in_dollars,
        coupon: @customer_order.promo_code || 'n/a'
      },
      other_details: {
        dimension1: @profile.owner_id || -1,
        dimension4: @customer_order.promo_code || 'n/a'
      }
    }
    @products_data = @customer_order.
      line_items.map(&:orderable).
      map{|gift| helpers.analytics_product_info(gift, @profile, {plain: true})}.
      to_json.html_safe
    key = action_name.to_sym
    data = step_options[key].merge(step_options[:other_details])
    if key == :finalize || data[:step] > 3
      data = data.merge(step_options[:customer_order_details])
    end
    @action_data = data.to_json.html_safe
  end

  def _add_promo!
    @promo = PromoCode.where('start_date <= ?', Date.today).find_by(value: @promo_code)
    if @promo.present?
      if @promo.end_date >= Date.today
        @customer_order.set_promo_code(@promo)
        @customer_order.save!
      else
        @promo_error_message = "We're Sorry &#8212; That code has expired.".html_safe
      end
    else
      @promo_error_message = "We're Sorry &#8212; We don't recognize that promo code.".html_safe
    end
  end

  def _load_progress_bar
    @pb = Ec::ProgressBarViewModel.new(@customer_order, @customer_purchase, @checkout_step)
  end

  def _load_service_object
    if params[:cart_id].present?
      session[:cart_id] = params[:cart_id]
    end

    if session[:cart_id].blank?
      return redirect_to :root
    end

    @customer_purchase = Ec::PurchaseService.new(cart_id: session[:cart_id])
    @customer_order = @customer_purchase.customer_order

    # Shouldn't be messing with orders that have been submitted
    if !@customer_purchase.in_progress? && params[:action] != 'finalize'
      flash[:alert] = "That order has already been submitted."
      return redirect_to :root
    end

    @profile = @customer_order.profile
  end

  def _load_addresses
    @saved_addresses = current_user.addresses
    @giftee_addresses = @profile.addresses

    if @customer_order.ship_to_customer? && @customer_order.address.nil? && @customer_order.ship_street1.blank?
      @customer_order.address = current_user.addresses.last
    elsif @customer_order.address.present?
      # make sure address id makes sense
      addressable = @customer_order.ship_to_customer? ? @customer_order.user : @customer_order.profile
      if addressable != @customer_order.address.addressable && !@customer_order.address.ship_address_is_equal_to_address?(@customer_order)
        @customer_order.address = nil
      end
    end

    @address_collection = @saved_addresses.map do |address|
      [ format_address(object: address), address.id]
    end || []
    @address_collection.push(['New Address', 'new_address'])
  end
end
