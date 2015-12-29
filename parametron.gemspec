# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parametron/version'

Gem::Specification.new do |spec|
  spec.name          = "parametron"
  spec.version       = Parametron::VERSION
  spec.authors       = ["Yury Batenko"]
  spec.email         = ["jurbat@gmail.com"]
  spec.description   = %q{DSL for method arguments validation and casting}
  spec.summary       = %q{DSL for method arguments validation and casting}
  spec.homepage      = "http://github.com/svenyurgensson/parametron"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version     = ">= 1.9"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

end
