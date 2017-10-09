require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WraptGratitude
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.test_framework false
      generate.jbuilder false
    end

    # Want to organize files but not namespace all the models there.
    config.autoload_paths << "#{Rails.root}/app/models/ecommerce"

    config.action_controller.include_all_helpers = false

    Rails.application.config.assets.precompile += ['admin.js', 'admin.css']

  end
end
