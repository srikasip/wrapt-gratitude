module Admin
  module Ecommerce
    class ParcelsController < BaseController
      before_action :_load_parcel, only: [:edit, :update, :destroy, :undestroy]

      def index
        @gift_parcels =     Ec::Parcel.by_weight.pretty.active.page(params[:gift_page])
        @shipping_parcels = Ec::Parcel.by_weight.shipping.active.page(params[:shipping_page])
        @inactive_parcels = Ec::Parcel.by_weight.inactive.page(params[:inactive_page])
      end

      def new
        @parcel = Ec::Parcel.new
      end

      def create
        @parcel = Ec::Parcel.new(_permitted_params)

        if @parcel.save
          flash[:notice] = 'Parcel created'
          redirect_to action: :index
        else
          flash.now[:alert] = "There was an error: #{@parcel.errors.full_messages.join('. ')}"
          render :new
        end
      end

      def edit
      end

      def update
        if @parcel.update_attributes(_permitted_params)
          flash[:notice] = "Saved"
          redirect_to action: :index
        else
          flash[:alert] = "There was an error"
          render :edit
        end
      end

      def destroy
        @parcel.update_attribute(:active, false)
        redirect_to action: :index
      end

      def undestroy
        @parcel.update_attribute(:active, true)
        redirect_to action: :index
      end

      private

      def _load_parcel
        @parcel = Ec::Parcel.find(params[:id])
      end

      def _permitted_params
        params.require(:ec_parcel).permit(:case_pack, :code, :color,
          :description, :height_in_inches, :length_in_inches,
          :shippo_template_name, :source, :stock_number,
          :usage, :weight_in_pounds, :width_in_inches)
      end
    end
  end
end
