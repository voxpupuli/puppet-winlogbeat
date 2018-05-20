require 'facter'
Facter.add('winlogbeat_version') do
  confine :kernel => %w[Windows] # rubocop:disable Style/HashSyntax
  if File.exist?('c:\Program Files\Winlogbeat\winlogbeat.exe')
    winlogbeat_version = Facter::Util::Resolution.exec('"c:\Program Files\Winlogbeat\winlogbeat.exe" --version')
  end
  setcode do
    %r{^winlogbeat version ([^\s]+)?}.match(winlogbeat_version)[1] unless winlogbeat_version.nil?
  end
end
