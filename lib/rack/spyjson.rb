require "rack/spyjson/version"
require "logger"

module Rack
  class SpyJSON
    def initialize(app, &configure)
      @app = app
      configure.call(self) if block_given?
    end
    attr_reader :app
    attr_accessor :logger

    def call(env)
      status_code, headers, body = @app.call(env)
      res = Rack::Response.new(body, status_code, headers)
      if res.content_type =~ /json/
        _logger = logger || env['rack.logger'] || env['rack.error'] || ::Logger.new(STDOUT)
        json = body.join
        if _logger.respond_to? :debug
          _logger.debug format_log_output(res, json)
        elsif _logger.respond_to? :write
          _logger.write format_log_output(res, json)
        else
          raise "Logger must be specified"
        end
      end
      return res.finish
    end

    private
    def format_log_output(res, json)
      <<-FORMAT % [res.status, compose_headers(res), pretty_json(json)]
** RESPONSE SPYED **
Status Code: %d
Headers:
%s
Body:
%s
      FORMAT
    end

    def pretty_json(json)
      CodeRay.scan(JSON.pretty_unparse(JSON.parse(json)), :json)
        .terminal
        .gsub(/^/m, "\t")
    end

    def compose_headers(res)
      res.headers.map {|k, v|
        if v.include? "\n"
          v = v.gsub(/\n/, "\n\t\t")
        end
        "\t#{red(k + ':')} #{v}"
      }.join("\n")
    end

    def red(key)
      "\e[31m#{key}\e[0m"
    end
  end
end
