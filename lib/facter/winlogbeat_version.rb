# frozen_string_literal: true

require 'facter'
Facter.add('winlogbeat_version') do
  confine :kernel => 'Windows' # rubocop:disable Style/HashSyntax
  if File.exist?('c:\Program Files\Winlogbeat\winlogbeat.exe')
    # Version 5.x and prior use --version syntax, 6.0 and newer uses just the version keyword. This check supports both versions
    winlogbeat_version = Facter::Util::Resolution.exec('"c:\Program Files\Winlogbeat\winlogbeat.exe" version')
    winlogbeat_version = Facter::Util::Resolution.exec('"c:\Program Files\Winlogbeat\winlogbeat.exe" --version') if winlogbeat_version.empty?
  end
  setcode do
    %r{^winlogbeat version ([^\s]+)?}.match(winlogbeat_version)[1] unless winlogbeat_version.nil?
  end
end
