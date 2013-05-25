# Parametron

This simple library implements DSL for validating method input parameters

## Installation

Add this line to your application's Gemfile:

    gem 'parametron'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install parametron

## Usage

```ruby

    class VictimStrict
        include Parametron

        params_for(:fetch, strict: true) do
          required :city,   validator: /\w+/
          required :year,   validator: /\d{4}/
          optional :title,  validator: ->(str){ str != "Moscow" }
          optional :number, validator: /\d+/, default: 42
        end

        def fetch params
          # .. do something useful
        end
      end

See `spec/parametron_spec` how this library suppossed to work.
All hackers do it and you should do!


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
