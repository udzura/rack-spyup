require 'json'
require 'rack-spyup'
require 'pry'

App = lambda do |env|
  json =
    {
      status: "OK",
      body: {hello: "World", rand: rand(10000)},
      array: ["this", "is", "array"]
    }.to_json
  [200, {"Content-Type" => "application/json"}, [json]]
end

use Rack::SpyUp
run App
