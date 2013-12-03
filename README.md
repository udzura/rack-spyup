# Rack::Spyjson

Spying request and json response

## Installation

Add this line to your application's Gemfile:

    gem 'rack-spyjson'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-spyjson

## Usage

```ruby
use Rack::SpyJSON do |config|
  config.logger = Logger.new(STDOUT)
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
