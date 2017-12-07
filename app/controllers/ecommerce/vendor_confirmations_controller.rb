class Ecommerce::VendorConfirmationsController < ApplicationController
  before_action :load_purchase_order, except: [:error]
  before_action :check_if_order_can_change, only: [:show, :update]

  def show
    @vendor = @purchase_order.vendor
  end

  def update
    if @purchase_order.update_attributes(po_attributes)
      FinalizeOrderJob.perform_later(@purchase_order.cart_id)
      redirect_to action: :details, id: params[:id]
    else
      flash.now[:error] = "There was a problem with saving your response."
      render :show
    end
  end

  def error
  end

  def details
  end

  def change_shipping
    service = @purchase_order.to_service

    service.force_shipping!({
      purchase_order: @purchase_order,
      shipping_carrier_id: params[:shipping_carrier][:id],
      shipping_service_level_id: params[:shipping_service_level][:id],
      parcel_id: params[:parcel][:id],
    })

    redirect_back(fallback_location: url_for(action: :show))
  end

  private

  def login_required?
    false
  end

  def load_purchase_order
    @purchase_order = Ec::PurchaseOrder.find_by(vendor_token: params[:id])

    if @purchase_order.present? && @purchase_order.shipment.present?
      @customer_order = @purchase_order.customer_order
      @shipping_carriers       = Ec::ShippingCarrier.active.all
      @shipping_service_levels = @purchase_order.shipping_carrier.shipping_service_levels
      @shipping_parcels        = @purchase_order.shipping_service_level.shipping_parcels
    else
      redirect_to(action: :error)
    end
  end

  def check_if_order_can_change
    return if @purchase_order.can_change_acknowledgements?

    redirect_to action: :details, id: params[:id]
  end

  def po_attributes
    permitted = params.require(:ec_purchase_order).permit(:vendor_acknowledgement_status, :vendor_acknowledgement_reason)

    if permitted[:vendor_acknowledgement_status] == Ec::PurchaseOrder::FULFILL
      permitted[:vendor_acknowledgement_reason] = nil
    end

    if permitted[:vendor_acknowledgement_reason] == 'other'
      permitted[:vendor_acknowledgement_reason] = params[:purchase_order][:other_reason]
    end

    permitted
  end
end
