class Parametron::ParamsValidator

  attr_accessor :required_vals, :optional_vals, :on_exception_handler

  def initialize(opts)
    @reject_unexpected = opts.fetch(:reject, true)
    @raise_on_excess   = opts.fetch(:strict, false)
    self.required_vals = []
    self.optional_vals = []
    self.on_exception_handler  = nil
  end

  def on_exception(lmbd)
    raise ArgumentError.new('on_exception expects lambda or proc') unless lmbd.respond_to? :call
    self.on_exception_handler = lmbd
  end

  def optional(name, opts={})
    default   = opts[:default]
    validator = opts[:validator]
    as        = opts[:as]
    cast      = opts[:cast]

    diff = opts.keys - [:default, :validator, :as, :cast]
    unless diff.empty?
      wrong_opts = diff.inject({}) {|acc, x| acc[x] = opts[x] }
      fail Parametron::ErrorMethodParams, "Unknown param given: #{wrong_opts}"
    end
    self.optional_vals << OptionalParameter.new(name.to_s, default, validator, as, cast)
  end

  def required(name, opts={})
    default   = opts[:default]
    validator = opts[:validator]
    as        = opts[:as]
    cast      = opts[:cast]

    diff = opts.keys - [:default, :validator, :as, :cast]
    unless diff.empty?
      wrong_opts = diff.inject({}) {|acc, x| acc[x] = opts[x] }
      fail Parametron::ErrorMethodParams, "Unknown param given: #{wrong_opts}"
    end
    self.required_vals << RequiredParameter.new(name.to_s, default, validator, as, cast)
  end

  def validate!(obj, params)
    obj.validation_error_cause = []
    normalized_param_keys = params.keys.map(&:to_s).sort
    exceed_params = normalized_param_keys - valid_keys

    if exceed_params.any?
      exceed_params.each do |par|
        obj.validation_error_cause << [par, params[par.to_sym]]
      end
      raise Parametron::ExcessParameter.new(exceed_params.to_s)  if @raise_on_excess
    end

    key_common = normalized_param_keys & required_keys
    if key_common != required_keys
      missing = required_keys - key_common
      obj.validation_error_cause << missing
      raise Parametron::RequiredParamError.new(missing)
    end

    params.each do |k, v|
      key = k.to_s
      unless valid_keys.include?(key)
        params.delete(key) if @reject_unexpected
        next
      end
      validators.find {|val| val.name == key }.tap do |curr_val|
        unless curr_val.valid?(v)
          obj.validation_error_cause << [key, v]
          fail Parametron::MalformedParams, key
        end
      end
    end
  end

  private

  def validators
    self.required_vals + self.optional_vals
  end

  def valid_keys
    validators.map {|x| x.name.to_s }.sort
  end

  def required_keys
    self.required_vals.map {|x| x.name.to_s }.sort
  end

  class GenericParameter < Struct.new(:name, :default, :validator, :as, :cast)
    def initialize(name, default, validator, as, cast)
      super
      unless as.nil? || String === as || Symbol === as
        fail ArgumentError, 'Parameter :as should be either String or Symbol!'
      end
    end

    def valid?(value)
      case self.validator
      when Regexp then value && !!self.validator.match(value.to_s)
      when Proc   then value && !!self.validator.call(value)
      else
        true
      end
    end
  end

  class OptionalParameter < GenericParameter
    def required?
      false
    end
  end

  class RequiredParameter < GenericParameter
    def required?
      true
    end
  end


end
