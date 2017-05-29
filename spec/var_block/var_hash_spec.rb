require 'spec_helper'

describe VarBlock::VarHash do
  it 'inherits from Hash' do
    var_hash = VarBlock::VarHash.new
    expect(var_hash).to be_a Hash
  end

  describe 'with' do
    it 'stores the variables arguments as a VarHash which is then passed into the block as the argument' do
      with var1: '1' do |v|
        v.with var2: 2 do |v|
          expect(v).to be_a VarBlock::VarHash
          expect(v[:var2]).to eq 2
        end
      end
    end

    it 'evaluates the block in the current context' do
      current_context = self

      with do |v|
        expect(self).to eq current_context
      end
    end

    it 'merges with the parent VarHash' do
      with var1: '1' do |v|
        v.with var2: 2 do |v|
          expect(v).to be_a VarBlock::VarHash
          expect(v[:var1]).to eq '1'
          expect(v[:var2]).to eq 2
        end
      end
    end

    it 'overrides the parent VarHash when "variables" already defined' do
      with var1: 1, var2: 2, var3: nil do |v|
        v.with var1: 'a', var2: 'b' do |v|
          expect(v[:var1]).to eq 'a'
          expect(v[:var2]).to eq 'b'
          expect(v[:var3]).to eq nil
        end
      end
    end
  end

  describe 'merge' do
    it 'merges the variable arguments with the current VarHash object, and wraps same-name variables into an Array if not yet an Array' do
      with fruits: 'apple', trees: 'oak' do |v|
        v.merge fruits: 'banana', vegetables: 'bean'
        expect(getvar(v, :fruits)).to eq %w[apple banana]
        expect(getvar(v, :vegetables)).to eq 'bean'
        expect(getvar(v, :trees)).to eq 'oak'
      end

      with fruits: 'apple' do |v|
        v.merge fruits: 'banana'
        v.merged_with fruits: ['grape', 'mango'] do |v|
          expect(getvar(v, :fruits)).to eq %w[apple banana grape mango]
        end
      end
    end

    it 'merges the variable arguments with the current VarHash object as a VarArray object' do
      with fruits: 'apple' do |v|
        v.merge fruits: 'banana'
        expect(v[:fruits].class).to eq VarBlock::VarArray
        expect(getvar(v, :fruits).class).to eq Array
      end
    end

    it 'cannot accept a block; merged_with is the one that accepts a block' do
      with fruits: 'apple' do |v|
        expect{
          v.merge(fruits: 'banana') { |v| }
        }.to raise_error ArgumentError, '`merge` does not accept a block. Are you looking for `merged_with` instead?'
      end
    end
  end

  describe 'merged_with' do
    it 'acts just just like with() except that if there are same-name variables, it merges them instead of overwriting them' do
      with fruits: 'apple' do |v|
        v.merged_with fruits: 'banana' do |v|
          expect(getvar(v, :fruits)).to eq %w[apple banana]
        end
      end
    end

    it 'does not affect the values of parent VarHash objects' do
      with fruits: 'apple' do |v|
        v.merged_with fruits: 'banana' do |vv|
        end

        expect(getvar(v, :fruits)).to eq 'apple'
      end

      with conditions: [] do |v|
        v.merged_with conditions: -> { true } do |vv|
          vv.merged_with conditions: -> { false } do |vvv|
          end

          expect(getvar(vv, :conditions)).to eq [true]
        end
      end
    end
  end
end
