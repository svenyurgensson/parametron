require "parametron/version"

module Parametron

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:attr_accessor, :validation_error_cause)
  end

  module ClassMethods
    attr_reader :params_validator
    def params(strict=false, &block)
      instance_eval do
        @params_validator = Parametron::ParamsValidator.new(strict)
        @params_validator.instance_eval(&block)
      end
    end
  end

  def fetch params
    _validate!(_set_defaults!(params))
  end


  private
  def _set_defaults!(params)
    new_par = params.dup
    _validators_list.each do |v|
      if new_par[v.name].nil? && new_par[v.name.to_sym].nil?
        new_par[v.name.to_sym] = v.default if v.default
      end
    end
    new_par
  end

  def _validate!(params)
    _params_validator.validate!(self, params)
    params
  end

  def _params_validator
    self.class.params_validator
  end

  def _validators_list
    _params_validator.required_vals + _params_validator.optional_vals
  end

  MalformedParams    = Class.new(ArgumentError)
  RequiredParamError = Class.new(ArgumentError)
  ErrorMethodParams  = Class.new(ArgumentError)
  ExcessParameter    = Class.new(ArgumentError)

end

require './parametron/params_validator'
