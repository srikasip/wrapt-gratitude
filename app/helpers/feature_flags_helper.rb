module FeatureFlagsHelper
  def require_invites?
    ENV.fetch('REQUIRE_INVITES') { 'true' } == 'false'
  end

  def checkout_enabled?
    value = ENV.fetch('CHECKOUT_ENABLED') { 'false' }
    value == 'true' || current_user&.admin?
  end

  def greenriver_person?
    current_user&.email.match(/greenriver/)
  end
end
