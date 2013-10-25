require "parametron/version"

module Parametron

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:attr_accessor, :validation_error_cause)
  end

  module ClassMethods
    attr_reader :params_validator
    # Declare known parameter keys
    # opts [Hash]
    #     :strict => false ; Raise exception on unknown key
    #     :reject => true  ; Reject unknown keys
    def params_for(method_name, opts={}, &block)
      instance_eval do
        @_method_name     = method_name.to_sym
        @params_validator = Parametron::ParamsValidator.new(opts)
        @params_validator.instance_eval(&block)
      end
    end

    def method_added(name)
      return if name != @_method_name or instance_variable_get(:"@_METHOD_#{name}_WRAPPED")
      instance_variable_set(:"@_METHOD_#{name}_WRAPPED", true)
      original = instance_method(name.to_sym)
      remove_method(name.to_sym)
      define_method(name) do |params={}|
        new_params = _rename_params!(_validate!(_set_defaults!(params)))
        original.bind(self).call(new_params)
      end
    end
  end

  private
  def _rename_params!(params)
    new_par = params.dup
    _validators_list.each do |v|
      next unless v.as
      new_par[v.as] = new_par.delete(v.name.to_sym) || new_par.delete(v.name.to_str)
    end
    new_par
  end

  def _set_defaults!(params)
    new_par = params.dup
    _validators_list.each do |v|
      if new_par[v.name].nil? && new_par[v.name.to_sym].nil?
        case v.default
        when nil  then next
        when Proc then new_par[v.name.to_sym] = v.default.call(self)
        else
          new_par[v.name.to_sym] = v.default
        end
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

require 'parametron/params_validator'
