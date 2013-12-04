require 'spec_helper'

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
end
