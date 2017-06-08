require 'spec_helper'

describe VarBlock::VarHash do
  it 'inherits from Hash' do
    var_hash = VarBlock::VarHash.new
    expect(var_hash).to be_a Hash
  end

  describe 'varblock_with' do
    it 'stores the variables arguments as a VarHash which is then passed into the block as the argument' do
      varblock_with var1: '1' do |v|
        v.varblock_with var2: 2 do |v|
          expect(v).to be_a VarBlock::VarHash
          expect(v[:var2]).to eq 2
        end
      end
    end

    it 'evaluates the block in the current context' do
      current_context = self

      varblock_with do |v|
        expect(self).to eq current_context
      end
    end

    it 'merges varblock_with the parent VarHash' do
      varblock_with var1: '1' do |v|
        v.varblock_with var2: 2 do |v|
          expect(v).to be_a VarBlock::VarHash
          expect(v[:var1]).to eq '1'
          expect(v[:var2]).to eq 2
        end
      end
    end

    it 'overrides the parent VarHash when "variables" already defined' do
      varblock_with var1: 1, var2: 2, var3: nil do |v|
        v.varblock_with var1: 'a', var2: 'b' do |v|
          expect(v[:var1]).to eq 'a'
          expect(v[:var2]).to eq 'b'
          expect(v[:var3]).to eq nil
        end
      end
    end
  end

  describe 'varblock_merge' do
    it 'merges the variable arguments varblock_with the current VarHash object, and wraps same-name variables into an Array if not yet an Array' do
      varblock_with fruits: 'apple', trees: 'oak' do |v|
        v.varblock_merge fruits: 'banana', vegetables: 'bean'
        expect(varblock_get(v, :fruits)).to eq %w[apple banana]
        expect(varblock_get(v, :vegetables)).to eq 'bean'
        expect(varblock_get(v, :trees)).to eq 'oak'
      end

      varblock_with fruits: 'apple' do |v|
        v.varblock_merge fruits: 'banana'
        v.varblock_merged_with fruits: ['grape', 'mango'] do |v|
          expect(varblock_get(v, :fruits)).to eq %w[apple banana grape mango]
        end
      end
    end

    it 'merges the variable arguments varblock_with the current VarHash object as a VarArray object' do
      varblock_with fruits: 'apple' do |v|
        v.varblock_merge fruits: 'banana'
        expect(v[:fruits].class).to eq VarBlock::VarArray
        expect(varblock_get(v, :fruits).class).to eq Array
      end
    end

    it 'cannot accept a block; varblock_merged_with is the one that accepts a block' do
      varblock_with fruits: 'apple' do |v|
        expect{
          v.varblock_merge(fruits: 'banana') { |v| }
        }.to raise_error ArgumentError, '`varblock_merge` does not accept a block. Are you looking for `varblock_merged_with` instead?'
      end
    end
  end

  describe 'varblock_merged_with' do
    it 'acts just just like varblock_with() except that if there are same-name variables, it merges them instead of overwriting them' do
      varblock_with fruits: 'apple' do |v|
        v.varblock_merged_with fruits: 'banana' do |v|
          expect(varblock_get(v, :fruits)).to eq %w[apple banana]
        end
      end
    end

    it 'does not affect the values of parent VarHash objects' do
      varblock_with fruits: 'apple' do |v|
        v.varblock_merged_with fruits: 'banana' do |vv|
        end

        expect(varblock_get(v, :fruits)).to eq 'apple'
      end

      varblock_with conditions: [] do |v|
        v.varblock_merged_with conditions: -> { true } do |vv|
          vv.varblock_merged_with conditions: -> { false } do |vvv|
          end

          expect(varblock_get(vv, :conditions)).to eq [true]
        end
      end
    end
  end
end
