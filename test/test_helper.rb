ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'capybara/rails'
require "rspec/mocks"
require "support/test_data"
require "support/loads_test_data"
require 'support/integration_test_authenticator'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new(:color => !ENV["MINITEST_NOCOLOR"]),
  ENV,
  Minitest.backtrace_filter

class ActiveSupport::TestCase
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
end

# include Rspec Mocks
module MinitestRSpecMocksIntegration
  include ::RSpec::Mocks::ExampleMethods

  def before_setup
    ::RSpec::Mocks.setup
    super
  end

  def after_teardown
    super
    ::RSpec::Mocks.verify
  ensure
    ::RSpec::Mocks.teardown
  end
end

Minitest::Test.send(:include, MinitestRSpecMocksIntegration)
RSpec::Mocks.configuration.verify_partial_doubles = true
