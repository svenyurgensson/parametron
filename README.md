# Parametron

This simple library implements DSL for validating and type casting input parameters for method.

## Installation

Add this line to your application's Gemfile:

    gem 'parametron', '>= 0.3'

And then execute:

    $ bundle

Or install it as:

    $ gem install parametron

## Usage

```ruby
    class VictimStrict
        include Parametron # <- should be at the top of class/module

        params_for(:fetch, strict: true) do
          required :city,   validator: /\w+/
          required :year,   validator: /\d{4}/
          optional :title,  validator: ->(str){ str != "Moscow" }, cast: ->(str){ str.upase }
          optional :number, validator: /\d+/, default: 42
          optional :gears,  default: ->(obj){ choose_by(obj) }
          optional :weel_d, as: :weel_diameter
          optional :load,   cast: Float
        end

        def fetch params
          # .. do something useful with params
        end
      end
```

The main aim of this small gem is to implement base AOP (aspect oriented programming) to separate validation, conversion and setting defaults for methods from real businnes logic which should be the only body of that method without validators, convertors, default setters overhead.

In order to get this functionality you only need to include `Parametron` module into top of your class and after that describe desired incoming parameters for method.

```ruby
    class Example
        include Parametron # <- should be at the top of class/module

        params_for(:fetch) do
            ...
        end
    end
```

Class method `params_for` accepts one or two arguments: first is symbolized name of method of interest and second one (optional) is hash of two options:

* `strict` which is defaultly set to `false`
* `reject` which is defaultly set to `false` too

`strict` when set to `true` means that when you call your method and try to send unknown (not described) key - it raise error `Parametron::ExcessParameter`
`reject` when set to `true` reject undescribed keys from method arguments

```ruby
    class ExampleStrict
        include Parametron # <- should be at the top of class/module

        params_for(:fetch, strict: true) do
            optional :one
        end

        def fetch par
        end
    end

    ex = ExampleStrict.new.fetch({unexpected: 'argument'})
    # => raises Parametron::ExcessParameter
```

```ruby
    class ExampleReject
        include Parametron # <- should be at the top of class/module

        params_for(:fetch, reject: true) do
            optional :one
        end

        def fetch par
          par
        end
    end

    ex = ExampleReject.new.fetch({one: '1', unexpected: 'argument'})
    p ex
    # => {one: '1'}
```

Method `params_for` should provide description block where you describe required and optional parameters for given method:

```ruby
    params_for(:fetch) do
      required :city,   validator: /\w+/
      required :year,   validator: /\d{4}/
      optional :title,  validator: ->(str){ str != "Moscow" }, cast: ->(str){ str.upase }
      optional :number, validator: /\d+/, default: 42
      optional :gears,  default: ->(obj){ choose_by(obj) }
      optional :weel_d, as: :weel_diameter
      optional :load,   cast: Float
    end
```

When parameter is `required` it must present in argument hash.
Instead, parameter described as `optional` might present but don't must.

All of that parameter descriptors can have such refinements:

* `validator` with `Regexp` or `proc` predicat to be sure that input parameter is valid
* `cast` which could be one of: `Integer`, `Float`, `proc` to convert input parameter
* `default` to set input parameter to its default value in case if it not presents
* `as` to rename input parameter name to new one






## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
