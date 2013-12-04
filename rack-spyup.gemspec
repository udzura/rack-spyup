# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/spyup/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-spyup"
  spec.version       = Rack::SpyUp::VERSION
  spec.authors       = ["Uchio KONDO"]
  spec.email         = ["udzura@udzura.jp"]
  spec.description   = %q{Spying requests and responses with rack power}
  spec.summary       = %q{Spying requests and responses with rack power, like json, msgpack, xml, and so on...}
  spec.homepage      = "https://github.com/udzura/rack-spyup"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rack", '>= 1.4'
  spec.add_runtime_dependency "coderay"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec", "~> 2.14.0"
  spec.add_development_dependency "rack-test"
end
