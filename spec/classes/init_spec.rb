require 'spec_helper'
describe 'winlogbeat' do

  context 'with default values for all parameters' do
    it { should contain_class('winlogbeat') }
  end
end
