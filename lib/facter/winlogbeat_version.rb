require 'facter'
Facter.add('winlogbeat_version') do
  confine 'kernel' => ['Windows']
  if File.exist?('c:\Program Files\Winlogbeat\winlogbeat.exe')
    winlogbeat_version = Facter::Util::Resolution.exec('"c:\Program Files\Winlogbeat\winlogbeat.exe" version')
    if winlogbeat_version.empty?
      winlogbeat_version = Facter::Util::Resolution.exec('"c:\Program Files\Winlogbeat\winlogbeat.exe" --version')
    end
  end
  setcode do
    winlogbeat_version.nil? ? false : %r{^winlogbeat version ([^\s]+)?}.match(winlogbeat_version)[1]
  end
end
