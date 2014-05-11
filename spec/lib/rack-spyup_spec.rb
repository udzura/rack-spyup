require 'spec_helper'
require 'stringio'
require 'json'

describe Rack::SpyUp do
  describe "should not smoke" do
    before do
      mock_app do
        use Rack::SpyUp do |mw|
          mw.logger = Logger.null_logger
        end
        run lambda {|env| [200, {"Content-Type" => "text/html"}, ["OK"]]}
      end
    end

    it "should be OK" do
      expect {
        get "/"
      }.not_to raise_error
    end

    it "should not affect response" do
      get "/"
      expect(last_response.body).to eq("OK")
    end
  end

  describe "options" do
    before do
      @output = StringIO.new
    end

    it "should contain colored log" do
      _logger = Logger.new(@output)
      mock_app do
        use Rack::SpyUp do |mw|
          mw.logger = _logger
          mw.colorize = true
        end
        run lambda {|env| [200, {"Content-Type" => "text/html"}, ["OK"]]}
      end

      get "/hello"
      @output.rewind
      expect(@output.read).to match(/\e\[\d+m/)
    end

    it "should not contain colored log when configured" do
      _logger = Logger.new(@output)
      mock_app do
        use Rack::SpyUp do |mw|
          mw.logger = _logger
          mw.colorize = false
        end
        run lambda {|env| [200, {"Content-Type" => "text/html"}, ["OK"]]}
      end

      get "/hello"
      @output.rewind
      expect(@output.read).not_to match(/\e\[\d+m/)
    end

    it "should not contain colored log when configured by 'Rack::SpyUp.config'" do
      Rack::SpyUp.config do |config|
        config.colorize = false
      end

      _logger = Logger.new(@output)
      mock_app do
        use Rack::SpyUp do |mw|
          mw.logger = _logger
        end
        run lambda {|env| [200, {"Content-Type" => "text/html"}, ["OK"]]}
      end

      get "/hello"
      @output.rewind
      expect(@output.read).not_to match(/\e\[\d+m/)
    end
  end

  describe "should display request info" do
    before do
      @output = StringIO.new
      _logger = Logger.new(@output)

      mock_app do
        use Rack::SpyUp do |mw|
          mw.logger = _logger
          mw.colorize = false
        end
        run lambda {|env| [200, {"Content-Type" => "text/html"}, ["OK"]]}
      end
    end

    it "should print request info" do
      header "Host", "udzura.example.jp"
      get "/hello"
      @output.rewind
      expect(@output.read).to match(%r|GET http://udzura.example.jp/hello|)
    end

    it "should contain custom header info" do
      header "X-Forwarder-For", "192.0.2.1,192.0.2.2"
      header "X-Foobar", "true"
      get "/"
      @output.rewind
      printed = @output.read

      expect(printed).to match(/X-Forwarder-For: 192.0.2.1,192.0.2.2/)
      expect(printed).to match(/X-Foobar: true/)
    end
  end

  describe "should display response info" do
    before do
      @output = StringIO.new
      @logger = Logger.new(@output)
    end

    let(:body) do
      {response: "OK"}.to_json
    end

    it "should print response info" do
      _logger = @logger
      _body = body

      mock_app do
        use Rack::SpyUp do |mw|
          mw.logger = _logger
          mw.colorize = false
        end
        run lambda {|env| [200, {"Content-Type" => "application/json"}, [_body]]}
      end

      get "/index.json"
      @output.rewind
      response = @output.read

      expect(response).to match(/Content-Type: application\/json/)
      expect(response).to match(/Content-Length: #{body.length}/)
      expect(response).to match(/Body:\s+{\s+"response": "OK"\s+}/m)
    end

    it "should contain custom response info, such as header" do
      _logger = @logger
      _body = body

      mock_app do
        use Rack::SpyUp do |mw|
          mw.logger = _logger
          mw.colorize = false
        end
        run lambda {|env|
          [200,
            {"Content-Type" => "application/json",
             "X-Powerd-By"  => "PHP/4.1.10"},
            [_body]]}
      end

      get "/index.json"
      @output.rewind
      response = @output.read

      expect(response).to match(/X-Powerd-By: PHP\/4.1.10/)
    end
  end
end
