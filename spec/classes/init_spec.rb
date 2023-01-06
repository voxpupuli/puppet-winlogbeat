# frozen_string_literal: true

require 'spec_helper'

describe 'winlogbeat' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context 'powershell version >=5' do
        let(:facts) do
          facts.merge({ 'psversion' => '5.1.2' })
        end

        it { is_expected.to contain_class('winlogbeat') }
      end

      context 'powershell version < 5' do
        let(:facts) do
          facts.merge({ 'psversion' => '3.1.0' })
        end

        it { is_expected.to contain_class('winlogbeat') }
      end
    end
  end
end
