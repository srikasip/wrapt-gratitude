module FeatureFlagsHelper
  def require_invites?
    ENV.fetch('REQUIRE_INVITES') { 'true' } == 'true'
  end

  def checkout_enabled?
    value = ENV.fetch('CHECKOUT_ENABLED') { 'false' }
    value == 'true' || current_user&.admin?
  end
end
