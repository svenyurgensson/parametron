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
        begin
          new_params = _rename_params!(_cast!(_validate!(_set_defaults!(params))))
        rescue => e
          if self.class.params_validator.on_exception_handler
            return self.class.params_validator.on_exception_handler.call(e)
          else
            raise e
          end
        end
        original.bind(self).call(new_params)
      end
    end
  end

  private
  def _cast!(params)
    new_par = params.dup
    _validators_list.each do |v|
      next unless v.cast
      key = v.name.to_sym
      val = new_par[key]
      next if val.nil? and not v.required?
      new_par[key] =
        case
        when v.cast.to_s == "Integer" then Integer(val)
        when v.cast.to_s == "Float"   then Float(val)
        when Proc === v.cast
          case v.cast.arity
          when 0 then v.cast.call()
          when 1 then v.cast.call(val)
          when 2 then v.cast.call(val, new_par)
          else v.cast.call(val, new_par, params)
          end
        else
          raise MalformedParams.new("Unknown cast type: '#{v.cast.inspect}'")
        end
    end
    new_par
  end

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
        when Proc
          case v.default.arity
          when 0 then new_par[v.name.to_sym] = v.default.call()
          when 1 then new_par[v.name.to_sym] = v.default.call(self)
          else
            raise ArgumentError.new "Too much arguments for #{v.name} default lambda"
          end
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
