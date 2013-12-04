# Rack::SpyUp

Spying request and json response

## Installation

Add this line to your application's Gemfile:

    gem 'rack-spyup'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-spyup

## Usage

```ruby
use Rack::SpyUp do |config|
  config.logger = Logger.new(STDOUT)
end
```

### `spyup` command

rack-spyup is shipped with `spyup` command.
You can use usual config.ru with request and response spyed:

```bash
$ spyup config.ru
```

`spyup` has the same options as `rackup` (except `--builder`),
because she uses `Rack::Server` internally.

## What you will see

![Just like this](https://raw.github.com/udzura/rack-spyup/master/docs/spyup.png)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
