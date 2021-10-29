# frozen_string_literal: true

require 'json'

# Stolen from https://souldodotnet.wordpress.com/2015/11/05/windows-powershell-and-puppet-structured-facts/
Facter.add(:psversiontable) do
  confine :kernel => :windows # rubocop:disable Style/HashSyntax
  setcode do
    powershell = if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                   "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
                 elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                   "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
                 else
                   'powershell.exe'
                 end
    query = "$ErrorActionPreference = 'SilentlyContinue';$psv = $PSVersionTable | ConvertTo-Json; $psv.ToLower()"
    response = JSON.parse(Facter::Util::Resolution.exec(%(#{powershell} -command "#{query}")))
    if response
      response
    else
      'unavailable'
    end
  end
end
