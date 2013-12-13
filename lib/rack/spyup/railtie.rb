require 'rails/railtie'
require 'rack/spyup'

module Rack
  class SpyUp
    class Railtie < ::Rails::Railtie
      config.rack_spyup = Rack::SpyUp.config

      initializer "rack_spyup.initialize_middleware" do |app|
        config = Rack::SpyUp.config
        if Rails.env.to_s.in?(config.enabled_environments.map(&:to_s))
          _logger = if config.logger && config.logger.respond_to?(:call)
                      config.logger.call()
                    elsif config.logger
                      config.logger
                    else
                      Rails.logger
                    end

          app.middleware.insert 0, Rack::SpyUp do |mw|
            mw.logger = _logger
          end
        end
      end
    end
  end
end
