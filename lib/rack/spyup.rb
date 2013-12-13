require "rack/spyup/version"
require "rack/spyup/configuration"
require "logger"

module Rack
  class SpyUp
    def initialize(app, &instance_configure)
      @app = app
      @colorize = true
      @logger   = self.class.config.logger
      instance_configure.call(self) if block_given?
    end
    attr_reader :app
    attr_accessor :logger, :colorize

    def call(env)
      return @app.call(env) if ignore_case?(env)

      req = Rack::Request.new(env)
      detected_logger(env).debug format_request_output(req)

      status_code, headers, body = @app.call(env)
      res = Rack::Response.new(body, status_code, headers)
      if res.content_type =~ /json/
        json = ""
        body.each{|part| json << part }
        detected_logger(env).debug format_response_output(res, json)
      end
      return res.finish
    end

    class << self
      def config(&global_configure)
        @__config ||= Rack::SpyUp::Configuration.default
        if block_given?
          global_configure.call(@__config)
        end
        @__config
      end
    end

    private
    def ignore_case?(env)
      # TODO more options to omit logging
      return true  if env["PATH_INFO"] =~ /favicon.ico$/
      return false
    end

    # Do not cache - run detection by each call
    def detected_logger(env)
      _logger = logger || env['rack.logger'] || env['rack.error'] || ::Logger.new(STDOUT)
      unless _logger.respond_to? :debug
        def _logger.debug(str)
          _logger.write(str)
        end
      end
      _logger
    end

    def format_request_output(req)
      body = req.body.read
      req.body.rewind
      <<-FORMAT % [to_request_line(req), compose_request_headers(req), body, format_cookies(req.cookies)]
** REQUEST SPYED **
Request:
\t%s
Headers:
%s
Body:
\t%s
Cookies:
%s
      FORMAT
    end

    def to_request_line(req)
      "#{req.request_method} #{req.url}"
    end

    def compose_request_headers(req)
      headers = <<-HEADERS.chomp
Content-Type: #{req.content_type}
Content-Length: #{req.content_length}
Remote: #{req.env['REMOTE_ADDR']}
      HEADERS
      req.env.each do |key, value|
        parts = key.scan(/^HTTP_([A-Z_]+)/).flatten.first
        next if parts.nil?
        _key = parts.split('_')
          .map{|part| part.sub(/(?<=^[A-Z])[A-Z]*/) {|m| m.downcase } }
          .join("-")
        headers << "\n" << "#{_key}: #{value}"
      end
      headers
        .gsub(/^[-a-zA-Z]+:/m, red('\0'))
        .gsub(/^/, "\t")
    end

    def format_cookies(cookies)
      return gray("\t<none>") if cookies.empty?
      cookies.map{|k, v|
        "\t#{red(k)} = #{cyan(v)}"
      }.join("\n")
    end

    def format_response_output(res, json)
      <<-FORMAT % [res.status, compose_response_headers(res), pretty_json(json)]
** RESPONSE SPYED **
Status Code: %d
Headers:
%s
Body:
%s
      FORMAT
    end

    def pretty_json(json)
      formatted = JSON.pretty_unparse(JSON.parse(json))
      formatted = CodeRay.scan(formatted, :json).terminal if colorize

      formatted.gsub(/^/m, "\t")
    end

    def compose_response_headers(res)
      res.headers.map {|k, v|
        if v.include? "\n"
          v = v.gsub(/\n/, "\n\t\t")
        end
        "\t#{red(k + ':')} #{v}"
      }.join("\n")
    end

    def red(key)
      return key unless colorize
      "\e[31m#{key}\e[0m"
    end

    def cyan(value)
      return value unless colorize
      "\e[36m#{value}\e[0m"
    end

    def gray(value)
      return value unless colorize
      "\e[37m#{value}\e[0m"
    end
  end
end

require "rack/spyup/railtie" if defined?(Rails)
