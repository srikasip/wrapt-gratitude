class HealthCheckController < ApplicationController
  skip_before_action :require_login
  skip_before_action :set_signed_authentication_cookie

  if ENV['BASIC_AUTH_USERNAME'].present? && ENV['BASIC_AUTH_PASSWORD'].present?
    skip_before_action :_basic_auth
  end

  def index
    Vendor.count
    head :ok
  end

  def exception
    raise "Exception on purpose for testing"
  end
end
