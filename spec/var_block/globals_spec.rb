require 'spec_helper'

describe VarBlock::Globals do
  describe 'varblock_get' do
    context 'when "variable" is not defined' do
      it 'raises an error' do
        varblock_with fruit: 'apple' do |v|
          expect{varblock_get(v, :vegetable)}.to raise_error ArgumentError, '2nd argument :vegetable is not defined. Defined are :fruit'
        end
      end
    end

    context 'when defined "variable" is generic (non-proc)' do
      it 'returns the value itself' do
        varblock_with fruit: 'apple' do |v|
          expect(varblock_get(v, :fruit)).to eq 'apple'
        end
      end
    end

    context 'when defined "variable" is a Proc' do
      it 'returns the "evaluated" value in the context of where varblock_get is called' do
        current_fruit = 'apple'

        varblock_with fruit: -> { current_fruit } do |v|
          expect(v[:fruit]).to be_a Proc
          expect(varblock_get(v, :fruit)).to eq 'apple'
        end
      end
    end

    context 'when defined "variable" is a Proc' do
      let(:variables) { { fruit: -> { current_fruit } } }

      it 'returns the "evaluated" value in the context of where varblock_get is called with the same binding' do
        pending 'TODO: find a good solution'

        current_fruit = 'apple'

        varblock_with variables do |v|
          expect(v[:fruit]).to be_a Proc
          expect(varblock_get(v, :fruit)).to eq 'apple'
        end
      end
    end

    context 'when defined "variable" is a Proc->VarArray' do
      it 'returns the "evaluated" value of each proc-item in the VarArray in the context of where varblock_get is called' do
        fruit1 = 'apple'
        fruit2 = 'banana'
        fruit3 = 'grape'
        fruit4 = 'mango'

        varblock_with fruits: -> { [fruit1, fruit2] } do |v|
          v.varblock_merge fruits: -> { [fruit3, fruit4] }

          expect(v[:fruits]).to be_a VarBlock::VarArray
          expect(varblock_get(v, :fruits)).to eq %w[apple banana grape mango]
        end
      end

      it 'returns the "non-evaluated" value of each generic-item in the VarArray in the context of where varblock_get is called' do
        varblock_with fruits: %w[apple banana] do |v|
          v.varblock_merge fruits: %w[grape mango]

          expect(v[:fruits]).to be_a VarBlock::VarArray
          expect(varblock_get(v, :fruits)).to eq %w[apple banana grape mango]
        end
      end
    end

    context 'when defined "variable" is a Proc->VarArray, and :truthy? option is passed' do
      it 'returns true if all items in the array are "truthy"' do
        varblock_with conditions: true && 1 == 1 do |v|
          v.varblock_merged_with conditions: 'foobar'.is_a?(String) do |v|
            expect(varblock_get(v, :conditions, :truthy?)).to be true
          end
        end

        condition1 = true
        condition2 = 1 == 1
        condition3 = 'foobar'.is_a?(String)

        varblock_with conditions: -> { condition1 && condition2 } do |v|
          v.varblock_merged_with conditions: -> { condition3 } do |v|
            expect(varblock_get(v, :conditions, :truthy?)).to be true
          end
        end
      end

      it 'returns false if at least one item is not "truthy"' do
        varblock_with conditions: true && 1 == 2 do |v|
          v.varblock_merged_with conditions: 'foobar'.is_a?(String) do |v|
            expect(varblock_get(v, :conditions, :truthy?)).to be false
          end
        end

        condition1 = true
        condition2 = 1 == 2
        condition3 = 'foobar'.is_a?(String)

        varblock_with conditions: -> { condition1 && condition2 } do |v|
          v.varblock_merged_with conditions: -> { condition3 } do |v|
            expect(varblock_get(v, :conditions, :truthy?)).to be false
          end
        end
      end

      it 'returns false immediately and not propagate/check remaining items in the list if at least one item is already not "truthy"' do
        varblock_with conditions: -> { true } do |v|
          v.varblock_merged_with conditions: -> { 1 == 2 } do |v|
            v.varblock_merged_with conditions: -> { raise('SOME ERROR') } do |v|
              expect{varblock_get(v, :conditions, :truthy?)}.to_not raise_error
              expect(varblock_get(v, :conditions, :truthy?)).to be false
            end
          end
        end
      end

      it 'returns true or false only even if the variables are non-boolean' do
        fruit1 = 'apple'
        varblock_with conditions: -> { true } do |v|
          v.varblock_merged_with conditions: -> { fruit1 } do |v|
            expect(varblock_get(v, :conditions, :truthy?)).to eq true
          end
        end

        fruit2 = nil
        varblock_with conditions: -> { true } do |v|
          v.varblock_merged_with conditions: -> { fruit2 } do |v|
            expect(varblock_get(v, :conditions, :truthy?)).to eq false
          end
        end
      end

      it 'has each Proc item evaluated in the context where varblock_get is called' do
        temp_struct = Struct.new(:condition1, :condition2) do
          def conditions_truthy?
            varblock_with conditions: -> { condition1 } do |v|
              v.varblock_merged_with conditions: -> { condition2 } do |v|
                return varblock_get(v, :conditions, :truthy?)
              end
            end
          end
        end

        temp_struct_object = temp_struct.new(true, true)
        expect{temp_struct_object.conditions_truthy?}.to_not raise_error
        expect(temp_struct_object.conditions_truthy?).to eq true
      end
    end

    context 'when defined "variable" is not a Proc->VarArray, and :truthy? option is passed' do
      it 'raises error because :truthy? option only works on merged-variables' do
        expected_error_message = ':truthy? option(s) are not supported on non-merged variables'

        varblock_with conditions: -> { 'apple' } do |v|
          expect{varblock_get(v, :conditions, :truthy?)}.to raise_error(ArgumentError, expected_error_message)
        end

        varblock_with conditions: 'apple' do |v|
          expect{varblock_get(v, :conditions, :truthy?)}.to raise_error(ArgumentError, expected_error_message)
        end

        varblock_with conditions: ['apple'] do |v|
          expect{varblock_get(v, :conditions, :truthy?)}.to raise_error(ArgumentError, expected_error_message)
        end
      end
    end

    context 'when defined "variable" is Proc->VarArray, and :any? option is passed' do
      it 'returns true if at least one item in the array is "truthy"' do
        varblock_with conditions: false do |v|
          v.varblock_merged_with conditions: false do |v|
            expect(varblock_get(v, :conditions, :any?)).to be false
          end
        end

        varblock_with conditions: false do |v|
          v.varblock_merged_with conditions: true do |v|
            expect(varblock_get(v, :conditions, :any?)).to be true
          end
        end

        condition1 = false
        condition2 = 1 == 2
        condition3 = 'foobar'.is_a?(String)

        varblock_with conditions: -> { condition1 && condition2 } do |v|
          v.varblock_merged_with conditions: -> { condition3 } do |v|
            expect(varblock_get(v, :conditions, :any?)).to be true
          end
        end

        condition1 = false
        condition2 = 1 == 2
        condition3 = 'foobar'.is_a?(Integer)

        varblock_with conditions: -> { condition1 && condition2 } do |v|
          v.varblock_merged_with conditions: -> { condition3 } do |v|
            expect(varblock_get(v, :conditions, :any?)).to be false
          end
        end
      end

      it 'returns false if all items are not "truthy"' do
        varblock_with conditions: false do |v|
          v.varblock_merged_with conditions: true do |v|
            expect(varblock_get(v, :conditions, :any?)).to be true
          end
        end

        condition1 = true
        condition2 = 1 == 2
        condition3 = 'foobar'.is_a?(String)

        varblock_with conditions: -> { condition1 && condition2 } do |v|
          v.varblock_merged_with conditions: -> { condition3 } do |v|
            expect(varblock_get(v, :conditions, :truthy?)).to be false
          end
        end
      end

      it 'returns true immediately and not propagate/check remaining items in the list if at least one item is already "truthy"' do
        varblock_with conditions: -> { false } do |v|
          v.varblock_merged_with conditions: -> { true } do |v|
            v.varblock_merged_with conditions: -> { raise('SOME ERROR') } do |v|
              expect{varblock_get(v, :conditions, :any?)}.to_not raise_error
              expect(varblock_get(v, :conditions, :any?)).to be true
            end
          end
        end
      end

      it 'returns true or false only even if the variables are non-boolean' do
        fruit1 = 'apple'
        varblock_with conditions: -> { false } do |v|
          v.varblock_merged_with conditions: -> { fruit1 } do |v|
            expect(varblock_get(v, :conditions, :any?)).to eq true
          end
        end

        fruit2 = nil
        varblock_with conditions: -> { false } do |v|
          v.varblock_merged_with conditions: -> { fruit2 } do |v|
            expect(varblock_get(v, :conditions, :any?)).to eq false
          end
        end
      end

      it 'has each Proc item evaluated in the context where varblock_get is called' do
        temp_struct = Struct.new(:condition1, :condition2) do
          def conditions_truthy?
            varblock_with conditions: -> { condition1 } do |v|
              v.varblock_merged_with conditions: -> { condition2 } do |v|
                return varblock_get(v, :conditions, :any?)
              end
            end
          end
        end

        temp_struct_object = temp_struct.new(false, false)
        expect{temp_struct_object.conditions_truthy?}.to_not raise_error
        expect(temp_struct_object.conditions_truthy?).to eq false
      end
    end

    context 'when defined "variable" is not a Proc->VarArray, and :any? option is passed' do
      it 'raises error because :any? option only works on merged-variables' do
        expected_error_message = ':any? option(s) are not supported on non-merged variables'

        varblock_with conditions: -> { 'apple' } do |v|
          expect{varblock_get(v, :conditions, :any?)}.to raise_error(ArgumentError, expected_error_message)
        end

        varblock_with conditions: 'apple' do |v|
          expect{varblock_get(v, :conditions, :any?)}.to raise_error(ArgumentError, expected_error_message)
        end

        varblock_with conditions: ['apple'] do |v|
          expect{varblock_get(v, :conditions, :any?)}.to raise_error(ArgumentError, expected_error_message)
        end
      end
    end

    context 'when an unsupported option is passed' do
      it 'raises an ArgumentError' do
        varblock_with fruit: -> { 'apple' } do |v|
          expect{varblock_get(v, :conditions, :somenonexistingoption)}.to raise_error(ArgumentError, '3rd argument options Array only supports [:truthy?, :any?]. Does not support :somenonexistingoption')
        end
      end
    end
  end

  describe 'with' do
    it 'stores the variables arguments as a VarHash which is then passed into the block as the argument' do
      varblock_with var1: '1', var2: 2, var3: true do |v|
        expect(v).to be_a VarBlock::VarHash
        expect(v[:var1]).to eq '1'
        expect(v[:var2]).to eq 2
        expect(v[:var3]).to eq true
      end
    end

    it 'evaluates the block in the current context' do
      current_context = self

      varblock_with do |v|
        expect(self).to eq current_context
      end
    end
  end
end
