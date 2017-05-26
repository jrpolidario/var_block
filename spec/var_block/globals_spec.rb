require 'spec_helper'

describe VarBlock::Globals do
  describe 'getvar' do
    context 'when "variable" is not defined' do
      it 'raises an error' do
        with fruit: 'apple' do |v|
          expect{getvar(v, :vegetable)}.to raise_error ArgumentError, '2nd argument :vegetable is not defined. Defined are :fruit'
        end
      end
    end

    context 'when defined "variable" is generic (non-proc)' do
      it 'returns the value itself' do
        with fruit: 'apple' do |v|
          expect(getvar(v, :fruit)).to eq 'apple'
        end
      end
    end

    context 'when defined "variable" is a Proc' do
      it 'returns the "evaluated" value in the context of where getvar is called' do
        current_fruit = 'apple'

        with fruit: -> { current_fruit } do |v|
          expect(v[:fruit]).to be_a Proc
          expect(getvar(v, :fruit)).to eq 'apple'
        end
      end
    end

    context 'when defined "variable" is a Proc' do
      let(:variables) { { fruit: -> { current_fruit } } }

      it 'returns the "evaluated" value in the context of where getvar is called with the same binding' do
        pending 'TODO: find a good solution'

        current_fruit = 'apple'

        with variables do |v|
          expect(v[:fruit]).to be_a Proc
          expect(getvar(v, :fruit)).to eq 'apple'
        end
      end
    end

    context 'when defined "variable" is a Proc->VarArray' do
      it 'returns the "evaluated" value of each proc-item in the VarArray in the context of where getvar is called' do
        fruit1 = 'apple'
        fruit2 = 'banana'
        fruit3 = 'grape'
        fruit4 = 'mango'

        with fruits: -> { [fruit1, fruit2] } do |v|
          v.merge fruits: -> { [fruit3, fruit4] }

          expect(v[:fruits]).to be_a VarBlock::VarArray
          expect(getvar(v, :fruits)).to eq %w[apple banana grape mango]
        end
      end

      it 'returns the "non-evaluated" value of each generic-item in the VarArray in the context of where getvar is called' do
        with fruits: %w[apple banana] do |v|
          v.merge fruits: %w[grape mango]

          expect(v[:fruits]).to be_a VarBlock::VarArray
          expect(getvar(v, :fruits)).to eq %w[apple banana grape mango]
        end
      end
    end

    context 'when defined "variable" is an Array or Proc->VarArray, and :truthy? option is passed' do
      it 'returns true if all items in the array are "truthy"' do
        with conditions: true && 1 == 1 do |v|
          v.merged_with conditions: 'foobar'.is_a?(String) do |v|
            expect(getvar(v, :conditions, :truthy?)).to be true
          end
        end

        condition1 = true
        condition2 = 1 == 1
        condition3 = 'foobar'.is_a?(String)

        with conditions: -> { condition1 && condition2 } do |v|
          v.merged_with conditions: -> { condition3 } do |v|
            expect(getvar(v, :conditions, :truthy?)).to be true
          end
        end
      end

      it 'returns false if at least one item is not "truthy"' do
        with conditions: true && 1 == 2 do |v|
          v.merged_with conditions: 'foobar'.is_a?(String) do |v|
            expect(getvar(v, :conditions, :truthy?)).to be false
          end
        end

        condition1 = true
        condition2 = 1 == 2
        condition3 = 'foobar'.is_a?(String)

        with conditions: -> { condition1 && condition2 } do |v|
          v.merged_with conditions: -> { condition3 } do |v|
            expect(getvar(v, :conditions, :truthy?)).to be false
          end
        end
      end

      it 'returns false immediately and not propagate/check remaining items in the list if at least one item is already not "truthy"' do
        with conditions: -> { true } do |v|
          v.merged_with conditions: -> { 1 == 2 } do |v|
            v.merged_with conditions: -> { raise('SOME ERROR') } do |v|
              expect{getvar(v, :conditions, :truthy?)}.to_not raise_error
              expect(getvar(v, :conditions, :truthy?)).to be false
            end
          end
        end
      end
    end
  end

  describe 'with' do
    it 'stores the variables arguments as a VarHash which is then passed into the block as the argument' do
      with var1: '1', var2: 2, var3: true do |v|
        expect(v).to be_a VarBlock::VarHash
        expect(v[:var1]).to eq '1'
        expect(v[:var2]).to eq 2
        expect(v[:var3]).to eq true
      end
    end

    it 'evaluates the block in the current context' do
      current_context = self

      with do |v|
        expect(self).to eq current_context
      end
    end
  end
end
