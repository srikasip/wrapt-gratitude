module FeatureFlagsHelper
  def require_invites?
    ENV.fetch('REQUIRE_INVITES') { 'true' } == 'true'
  end
end
