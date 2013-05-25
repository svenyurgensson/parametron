require 'spec_helper'

describe Parametron do

  context 'Params' do
    context '.params' do
      it 'accepts params block' do
        expect do
          class Victim
            include Parametron
            params_for(:_) do; end
          end
        end.not_to raise_error
      end
    end

    context '.optional' do
      it 'accepts optional params' do
        expect do
          class Victim
            include Parametron
            params_for(:_) do
              optional :city, default: ''
            end
          end
        end.not_to raise_error
      end

      it 'accepts defaults and validator params' do
        expect do
          class Victim
            include Parametron
            params_for(:_) do
              optional :city, default: '', validator: /\d+/
            end
          end
        end.not_to raise_error
      end

      it 'store params validator' do
        class Victim
          include Parametron
          params_for(:_) do
            optional :city, default: '', validator: /\d+/
          end
        end
        Victim.params_validator.should be_kind_of(Parametron::ParamsValidator)
        Victim.params_validator.required_vals.should be_empty
        Victim.params_validator.optional_vals.should have(1).items
      end

    end # context .optional


    context '.required' do
      it 'accepts required params' do
        expect do
          class Victim
            include Parametron
            params_for(:_) do
              required :city, default: ''
            end
          end
        end.not_to raise_error
      end

      it 'accepts defaults and validator params' do
        expect do
          class Victim
            include Parametron
            params_for(:_) do
              required :city, default: '', validator: /\d+/
            end
          end
        end.not_to raise_error
      end

      it 'store params validator' do
        class Victim
          include Parametron
          params_for(:_) do
            required :city, default: '', validator: /\d+/
          end
        end
        Victim.params_validator.should be_kind_of(Parametron::ParamsValidator)
        Victim.params_validator.optional_vals.should be_empty
        Victim.params_validator.required_vals.should have(1).items
      end

    end # context .required


    context '.validate' do
      class VictimStrict
        include Parametron
        params_for(:fetch, strict: true) do
          required :city,  validator: /\w+/
          required :year,  validator: /\d+/, default: 2012
          optional :title, validator: /\w+/
          optional :other, default: 'staff'
        end
        def fetch params
        end
      end
      class VictimRelaxed
        include Parametron
        params_for(:fetch) do
          required :city,  validator: /\w+/
          required :year,  validator: /\d+/, default: 2012
          optional :title, validator: /\w+/
          optional :other, default: 'staff'
        end
        def fetch params
        end
      end

      subject{ VictimStrict.new }

      it 'accepts valid params' do
        expect do
          subject.fetch({city: 'Moskow', year: '1917', title: 'Nothing', other: 'Not need'})
        end.not_to raise_error
      end

      it 'raise error when required param absent' do
        expect do
          subject.fetch({year: 1917, title: 'Nothing', other: 'Not need'})
        end.to raise_error(Parametron::RequiredParamError)
        subject.validation_error_cause.should eql [["city"]]
      end


      context "when strict" do
        subject{ VictimStrict.new }

        it 'raise on unknown params' do
          expect do
            subject.fetch({city: 'Moskow', year: 1917, title: 'Nothing', other: 'Not need', invalid: 'Yes'})
          end.to raise_error(Parametron::ExcessParameter)
          subject.validation_error_cause.should eql [["invalid", "Yes"]]
        end
      end # context strict

      context "when not strict" do
        subject{ VictimRelaxed.new }

        it 'not raise on unknown params' do
          expect do
            subject.fetch({city: 'Moskow', year: 1917, title: 'Nothing', other: 'Not need', invalid: 'Yes'})
          end.not_to raise_error
          subject.validation_error_cause.should eql [["invalid", "Yes"]]
        end
      end # context not strict

    end # context .validate

    context 'setting defaults for parameters' do
      class VictimWithDef
        include Parametron
        params_for(:fetch, strict: true) do
          required :city,  validator: /\w+/
          required :year,  validator: /\d+/, default: '2012'
          optional :title, validator: /\w+/
          optional :other,                   default: 'staff'
        end
        attr_reader :city, :year, :title, :other

        def fetch params
          @city = params[:city]
          @year = params[:year]
          @title= params[:title]
          @other= params[:other]
        end
      end

      let(:par){{city: 'Krasn', title: 'No way'}}
      let(:par_full){{city: 'Krasn', year: '2000', title: 'No way', other: 'KillAll'}}

     it 'accepts params' do
        expect do
          @obj = VictimWithDef.new
          @obj.fetch(par)
        end.not_to raise_error
      end

      it 'set defaults' do
        @obj = VictimWithDef.new
        @obj.fetch(par)
        @obj.city.should  eql par[:city]
        @obj.title.should eql par[:title]
        @obj.year.should  eql '2012'
        @obj.other.should eql 'staff'
      end

      it 'given params have advantage over defaults' do
        @obj = VictimWithDef.new
        @obj.fetch(par_full)
        @obj.city.should  eql par_full[:city]
        @obj.title.should eql par_full[:title]
        @obj.year.should  eql par_full[:year]
        @obj.other.should eql par_full[:other]
      end
    end


  end # context Params

end
