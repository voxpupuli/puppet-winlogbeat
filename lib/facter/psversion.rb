# frozen_string_literal: true

require 'json'

# Stolen from https://souldodotnet.wordpress.com/2015/11/05/windows-powershell-and-puppet-structured-facts/
Facter.add(:psversion) do
  confine :osfamily => :windows # rubocop:disable Style/HashSyntax
  setcode do
    powershell = if Facter::Core::Execution.which('powershell.exe')
                   Facter::Core::Execution.which('powershell.exe')
                 elsif File.exist?("#{ENV.fetch('SYSTEMROOT', nil)}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                   "#{ENV.fetch('SYSTEMROOT', nil)}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
                 elsif File.exist?("#{ENV.fetch('SYSTEMROOT', nil)}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                   "#{ENV.fetch('SYSTEMROOT', nil)}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
                 end
    query = 'Write-Host $PSVersionTable.PSVersion.ToString()'
    response = Facter::Core::Execution.execute(%(#{powershell} -command "#{query}"))
    response if %r{^\d+(\.\d+)+$} =~ response
  end
end
