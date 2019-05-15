require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'winrm'

ENV['BEAKER_PUPPET_AGENT_VERSION'] = '5.3.7'
ENV['BEAKER_PUPPET_COLLECTION'] = 'puppet5'
ENV['AWS_REGION'] = 'eu-west-1'

hosts.each do |host|
  case host['platform']
  when %r{windows}
    include Serverspec::Helper::Windows
    include Serverspec::Helper::WinRM

    version = ENV['PUPPET_VERSION'] || '5.3.7'

    install_puppet(version: version)

  else
    install_puppet
  end
end

# run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

UNSUPPORTED_PLATFORMS = ['aix', 'Solaris', 'BSD', 'linux'].freeze

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(source: module_root, module_name: 'winlogbeat')
  end
end

shared_examples 'an idempotent resource' do
  it 'apply with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'apply a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, catch_changes: true)
  end
end
