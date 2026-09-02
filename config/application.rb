require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"

require "action_controller/railtie"
require "action_mailer/railtie"

require "action_view/railtie"
require "action_cable/engine"
require "active_record/railtie"

Bundler.require(*Rails.groups)

module AiShopAssistant
  class Application < Rails::Application
    config.load_defaults 8.1


    config.autoload_lib(ignore: %w[assets tasks])

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
