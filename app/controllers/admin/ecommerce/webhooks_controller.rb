module Admin
  module Ecommerce
    class WebhooksController < ApplicationController
      skip_before_action :_basic_auth if ENV['BASIC_AUTH_USERNAME'].present? && ENV['BASIC_AUTH_PASSWORD'].present?

      skip_before_action :verify_authenticity_token

      def tracking
        Rails.logger.debug { "Body: #{request.body.read}" }
        Rails.logger.info { "Params: #{params.to_unsafe_h.inspect}" }

        webhook = ShippoTrackingWebhook.new(params.to_unsafe_h)
        webhook.run!

        head :ok
      end

      def login_required?
        false
      end
    end
  end
end
