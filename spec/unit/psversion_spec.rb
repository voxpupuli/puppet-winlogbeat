require 'spec_helper'
require 'facter/psversion'

describe Facter::Util::Fact do
  describe 'psversion', type: :fact do
    after { Facter.clear }
    subject { Facter.fact(:psversion) }

    on_supported_os.each do |os, facts|
      before do
        Facter.clear
        allow(Facter.fact(:osfamily)).to receive(:value).and_return(facts[:osfamily])
      end
      powershell = 'C:\\powershell.exe'
      query = 'Write-Host $PSVersionTable.PSVersion.ToString()'
      context "on os: #{os}" do
        before do
          allow(Facter::Core::Execution).to receive(:which).with('powershell.exe').and_return('C:\\powershell.exe')
          allow(File).to receive(:exist).with("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe").and_return(false)
          allow(File).to receive(:exist).with("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe").and_return(false)
        end
        it do
          # catch scenario where value is not nil due to inappropriate contain for :osfamily
          expect(Facter.fact(:osfamily).value).to eq('windows')
        end
        context 'Succeed with standard x.x.x format' do
          before do
            allow(Facter::Core::Execution).to receive(:execute).with(%(#{powershell} -command "#{query}")).and_return('7.1.2')
          end
          it do
            expect(Facter.fact(:psversion).value).to eq('7.1.2')
          end
        end
        context 'Succeed with less standard x.x.x.x.x format' do
          before do
            allow(Facter::Core::Execution).to receive(:execute).with(%(#{powershell} -command "#{query}")).and_return('7.1222.244.4222.111')
          end
          it do
            expect(Facter.fact(:psversion).value).to eq('7.1222.244.4222.111')
          end
        end
        context 'failures' do
          context 'nil on error text return' do
            before do
              allow(Facter::Core::Execution).to receive(:execute).with(%(#{powershell} -command "#{query}")).and_return('Error...')
            end
            it do
              expect(Facter.fact(:psversion).value).to be_nil
            end
          end
        end
      end
    end
  end
end
