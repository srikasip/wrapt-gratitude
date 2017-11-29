module Admin
  module Ecommerce
    class PromoCodesController < BaseController
      skip_before_action :verify_authenticity_token
      before_action :_load_promo_code, only: [:edit, :update, :destroy]

      def index
        @future_promo_codes = PromoCode.well_sorted.future.page(params[:future_page])
        @promo_codes = PromoCode.well_sorted.current.page(params[:page])
        @past_promo_codes = PromoCode.well_sorted.past.page(params[:other_page])
      end

      def create
        PromoCode.create!
        flash[:notice] = 'Promo code created'
        redirect_to action: :index
      end

      def edit
      end

      def update
        if @promo_code.update_attributes(_permitted_params)
          flash[:notice] = "Saved"
          redirect_to action: :index
        else
          flash[:alert] = "There was an error"
          render :edit
        end
      end

      def destroy
        @promo_code.update_attribute(:end_date, Date.today-1)
        redirect_to action: :index
      end

      private

      def _load_promo_code
        @promo_code = PromoCode.find(params[:id])
      end

      def _permitted_params
        params.require(:promo_code).permit(:amount, :description, :end_date, :mode, :start_date, :value)
      end
    end
  end
end
