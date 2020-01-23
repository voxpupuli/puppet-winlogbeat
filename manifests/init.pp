# This class installs the Elastic winlogbeat log shipper and
# helps manage which logs are shipped
#
# @example
# class { 'winlogbeat':
#   outputs => {
#     'logstash' => {
#       'hosts' => [
#         'localhost:5044',
#       ],
#     },
#   },
# }
#
# @param package_ensure [String] The ensure parameter for the winlogbeat package (default: present)
# @param service_ensure [String] The ensure parameter on the winlogbeat service (default: running)
# @param service_enable [String] The enable parameter on the winlogbeat service (default: true)
# @param spool_size [Integer] How large the spool should grow before being flushed to the network (default: 2048)
# @param idle_timeout [String] How often the spooler should be flushed even if spool size isn't reached (default: 5s)
# @param publish_async [Boolean] If set to true winlogbeat will publish while preparing the next batch of lines to send (defualt: false)
# @param registry_file [String] The registry file used to store positions, absolute or relative to working directory (default .winlogbeat)
# @param registry_flush [String] The timeout value that controls when registry entries are written to disk (default: 0s)
# @param config_dir_mode [String] The unix permissions mode set on the configuration directory (default: 0755)
# @param config_dir_owner [String] The owner set on the configuration directory (default: Administrator)
# @param config_dir_group [String] The group set on the configuration directory (default: Administrators)
# @param config_file_mode [String] The unix permissions mode set on configuration files (default: 0644)
# @param config_file_owner [String] The owner set on configuration files (default: Administrator)
# @param config_file_group [String] The group set on configuration files (default: Administrators)
# @param outputs [Hash] Will be converted to YAML for the required outputs section of the configuration (see documentation, and above)
# @param logging [Hash] Will be converted to YAML to create the optional logging section of the winlogbeat config (see documentation)
# @param run_options [Hash] Will be converted to YAML to create optionnal run options section of the winlogbeat config
# @param conf_template [String] The configuration template to use to generate the main winlogbeat.yml config file
# @param download_url [String] The URL of the zip file that should be downloaded to install winlogbeat (windows only)
# @param install_dir [String] Where winlogbeat should be installed (windows only)
# @param folder_name [String] The folder name to use to install winlogbeat (default: Winlogbeat)
# @param tmp_dir [String] Where winlogbeat should be temporarily downloaded to so it can be installed (windows only)
# @param shutdown_timeout [String] How long winlogbeat waits on shutdown for the publisher to finish sending events
# @param beat_name [String] The name of the beat shipper (default: hostname)
# @param tags [Array] A list of tags that will be included with each published transaction
# @param queue_size [String] The internal queue size for events in the pipeline
# @param max_procs [Integer] The maximum number of CPUs that can be simultaneously used
# @param fields [Hash] Optional fields that should be added to each event output
# @param fields_under_root [Boolean] If set to true, custom fields are stored in the top level instead of under fields
# @param processors [Array] Processors that will be added. Commonly used to create processors using hiera.
# @param disable_config_test [Boolean] Disable the configuration testing before to restart Winlogbeat servie (Default: false)
# @param setup [Hash] setup that will be created. Commonly used to create setup using hiera
# @param proxy_address [String] Proxy server to use for downloading files
# @param xpack [Hash] Configuration items to export internal stats to a monitoring Elasticsearch cluster
# @param queue [Hash] Will be converted to YAML to create the optional queue section of the winlogbeat config (see documentation)
# @param event_logs [Array[Hash]] Will be converted to Yaml to create the event_logs section of the winlogbeat
class winlogbeat (
  String  $package_ensure,
  Stdlib::Ensure::Service $service_ensure,
  Boolean $service_enable,
  Optional[String] $service_provider,
  Integer $spool_size,
  String  $idle_timeout,
  Boolean $publish_async,
  String  $registry_file,
  Optional[String] $registry_flush,
  String  $config_file,
  Optional[String] $config_file_owner,
  Optional[String] $config_file_group,
  Stdlib::Filemode  $config_dir_mode,
  Stdlib::Filemode  $config_file_mode,
  Optional[String] $config_dir_owner,
  Optional[String] $config_dir_group,
  Hash    $outputs,
  Hash    $logging,
  Hash    $run_options,
  String  $conf_template,
  Optional[String] $download_url,
  Optional[String]  $install_dir,
  String $folder_name,
  String  $tmp_dir,
  String  $shutdown_timeout,
  String  $beat_name,
  Array   $tags,
  Integer $queue_size,
  Optional[Integer] $max_procs,
  Hash $fields,
  Boolean $fields_under_root,
  Boolean $disable_config_test,
  Hash    $setup,
  Hash    $queue,
  Hash $processors,
  Array[Hash] $event_logs,
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $proxy_address, # lint:ignore:140chars
  Optional[Hash] $xpack,
  String $kernel_fail_message,
) {

  include ::stdlib

  if ($::kernel != 'Windows') {
    fail($kernel_fail_message)
  }

  $url_arch = $::architecture ? {
    'x86'   => 'x86',
    'x64'   => 'x86_64',
    default => fail("${::architecture} is not supported by filebeat."),
  }

  $real_download_url = $download_url ? {
    undef   => "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-${package_ensure}-windows-${url_arch}.zip",
    default => $download_url,
  }

  if $config_file != 'C:/Program Files/Winlogbeat/winlogbeat.yml' {
    warning('You\'ve specified a non-standard config_file location - winlogbeat may fail to start unless you\'re doing something to fix this') # lint:ignore:140chars
  }

  if $package_ensure == 'absent' {
    $ensure = 'absent'
    $alternate_ensure = 'absent'
    $real_service_ensure = 'stopped'
    $file_ensure = 'absent'
    $directory_ensure = 'absent'
  } else {
    $ensure = 'present'
    $alternate_ensure = 'present'
    $file_ensure = 'file'
    $directory_ensure = 'directory'
    $real_service_ensure = $service_ensure
  }

  # If we're removing winlogbeat, do things in a different order to make sure
  # we remove as much as possible
  contain ::winlogbeat::install
  contain ::winlogbeat::config
  contain ::winlogbeat::service

  if $ensure == 'absent' {
    Class['::winlogbeat::service']
    -> Class['::winlogbeat::config']
    -> Class['::winlogbeat::install']
  } else {
    Class['::winlogbeat::install']
    -> Class['::winlogbeat::config']
    -> Class['::winlogbeat::service']
  }
}
