require 'spec_helper'

describe Parametron, "On exception" do

  it 'accepts on_exception handler' do
    expect do
      class VictimWithOnExceptionHandlerTest
        include Parametron
        params_for(:fetch, strict: true) do
          required :title, validator: /\w+/
          on_exception -> e {}
        end
        def fetch params; params; end
      end
    end.not_to raise_error
  end

  it 'calls on_exeption handler on exception raised in params' do
    class VictimWithOnExceptionHandler1
      include Parametron
      params_for(:fetch, strict: true) do
        required :title, validator: /\w+/
        on_exception -> e { [false, e] }
      end
      def fetch params; params; end
    end

    v = VictimWithOnExceptionHandler1.new
    expect do
      v.fetch()
    end.not_to raise_error

    result = v.fetch()
    expect(result[0]).to eq false
    expect(result[1]).to be_an_instance_of(Parametron::RequiredParamError)
  end

end
