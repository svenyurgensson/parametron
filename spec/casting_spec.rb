require 'spec_helper'

describe Parametron, "Casting" do

  context 'accepts and provide casting input values' do
    it 'knows cast parameter' do
      expect do
        class Victim
          include Parametron
          params_for(:fetch) do
            required :year,  validator: /\d+/, cast: Float
          end
          def fetch(params); params; end
        end
      end.not_to raise_error
    end

    it 'cast input value to Integer' do
      class VictimI
        include Parametron
        params_for(:fetch) do
          required :year,  validator: /\d+/, cast: Integer
        end
        def fetch(params); params; end
      end

      v = VictimI.new
      expect do
        v.fetch(year: '1974')
      end.not_to raise_error
      res = v.fetch(year: '1974')
      res[:year].should == 1974
    end

    it 'cast input value to Float' do
      class VictimF
        include Parametron
        params_for(:fetch) do
          required :weight,  validator: /\A[.\d]+\z/, cast: Float
        end
        def fetch(params); params; end
      end

      v = VictimF.new
      expect do
        v.fetch(weight: '94.55')
      end.not_to raise_error
      res = v.fetch(weight: '94.55')
      res[:weight].should == 94.55
    end


    it 'cast input value using proc' do
      class VictimP
        include Parametron
        params_for(:fetch) do
          required :name,  cast: -> n { n.upcase }
        end
        def fetch(params); params; end
      end

      res = VictimP.new.fetch(name: 'use proc')
      res[:name].should == "USE PROC"
    end

    it 'cast input value using proc and have access to already casted params' do
      class VictimDoubleCast
        include Parametron
        params_for(:fetch) do
          required :year,  cast: -> x { Integer(x) + 12 }
          required :name,  cast: -> n, c { n.upcase + " #{c[:year]}"  }
        end
        def fetch(params); params; end
      end

      res = VictimDoubleCast.new.fetch(year: '1976', name: 'use proc')
      res[:name].should == "USE PROC 1988"
    end


    context "when params cannot be casted to given class" do
      it 'raises exception when not Integer' do
        class Victim3
          include Parametron
          params_for(:fetch) do
            required :year, cast: Integer
          end
          def fetch(params); params; end
        end

        expect do
          Victim3.new.fetch(year: 'Not Year')
        end.to raise_error
      end



    end

    it 'not raises exception on casting when parameter not required' do
        class VictimNotStrict
          include Parametron
          params_for(:fetch) do
            optional :year, cast: Integer
          end
          def fetch(params); params; end
        end

        expect do
          VictimNotStrict.new.fetch()
        end.not_to raise_error
      end



  end

end
