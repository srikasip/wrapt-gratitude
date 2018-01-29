class Ecommerce::PromoCodesController < ApplicationController

  before_action :load_promo

  def validate
    respond_to do |f|
      f.js {render layout: false}
    end
  end

  private

  def load_promo
    @promo_code = params[:promo_code]
    if @promo_code.present?
      @promo = PromoCode.
        where('start_date <= ?', Date.today).
        find_by(value: @promo_code)
      if @promo.present?
        if @promo.end_date <= Date.today
          @promo_error_message = "We're Sorry &#8212; That code has expired.".html_safe
        end
      else
        @promo_error_message = "We're Sorry &#8212; We don't recognize that promo code.".html_safe
      end
    end
  end

end