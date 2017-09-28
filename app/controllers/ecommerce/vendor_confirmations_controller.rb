module Ecommerce
  class VendorConfirmationsController < ApplicationController
    before_action :load_purchase_order, except: [:error, :thanks]
    before_action :check_if_order_can_change, except: [:error, :thanks]

    def show
      if @purchase_order.blank?
        redirect_to action: :error
      else
        @vendor = @purchase_order.vendor
      end
    end

    def update
      if @purchase_order.update_attributes(po_attributes)
        FinalizeOrderJob.perform_later(@purchase_order.cart_id)
        redirect_to action: :thanks
      else
        flash.now[:error] = "There was a problem with saving your response."
        render :show
      end
    end

    def error
    end

    def thanks
    end

    private

    def login_required?
      false
    end

    def load_purchase_order
      @purchase_order = PurchaseOrder.find_by(vendor_token: params[:id])
    end

    def check_if_order_can_change
      return if @purchase_order.can_change_acknowledgements?

      flash[:error] = "The order has already gone through. Please talk to wrapt support."
      redirect_to action: :error
    end

    def po_attributes
      permitted = params.require(:purchase_order).permit(:vendor_acknowledgement_status, :vendor_acknowledgement_reason)

      if permitted[:vendor_acknowledgement_status] == PurchaseOrder::FULFILL
        permitted[:vendor_acknowledgement_reason] = nil
      end

      permitted
    end
  end
end
