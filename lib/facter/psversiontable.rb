# frozen_string_literal: true
require 'json' 

# Stolen from https://souldodotnet.wordpress.com/2015/11/05/windows-powershell-and-puppet-structured-facts/
Facter.add(:psversiontable) do
  confine :kernel => :windows
  setcode do
    powershell = if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
      "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
    elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
      "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
    else
      "powershell.exe"
    end
    query = "$ErrorActionPreference = 'SilentlyContinue';$psv = $PSVersionTable | ConvertTo-Json; $psv.ToLower()"
    response = JSON.parse(Facter::Util::Resolution.exec(%Q{#{powershell} -command "#{query}"}))
    if response
      response
    else
      "unavailable"
    end
  end
end
