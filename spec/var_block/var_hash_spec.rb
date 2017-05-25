require 'spec_helper'

describe VarBlock::VarHash do
  it 'inherits from Hash' do
    var_hash = VarBlock::VarHash.new
    expect(var_hash).to be_a Hash
  end

  pending 'with'

  describe 'merge' do
    it 'merges the variable arguments with the current VarHash object, and wraps same-name variables into an Array if not yet an Array' do
      with fruits: 'apple', trees: 'oak' do |v|
        v.merge fruits: 'banana', vegetables: 'bean'
        expect(getvar(v, :fruits)).to eq %w[apple banana]
        expect(getvar(v, :vegetables)).to eq 'bean'
        expect(getvar(v, :trees)).to eq 'oak'
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
  end
end
