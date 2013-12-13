require 'rack/spyup'
module Rack
  class SpyUp
    class Configuration
      attr_accessor :enabled_environments, :logger

      def self.default
        new.tap do |config|
          config.enabled_environments = %w(development)
          config.logger = nil
        end
      end
    end
  end
end
